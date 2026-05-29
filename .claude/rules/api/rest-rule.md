# External API Integration Rules

These rules apply to all code that communicates with third-party APIs (example, example, VWorld, etc.).

## HttpClient Usage

- Always use `Symfony\Contracts\HttpClient\HttpClientInterface` — never use `curl`, `file_get_contents`, or Guzzle directly.
- Inject via Constructor Injection — never instantiate `HttpClient::create()` in a Service.
- Configure named HTTP clients in `config/packages/framework.yaml` (`framework.http_client.scoped_clients`) for each external provider — do not share one client across providers.
- Set `timeout`, `max_redirects`, and `verify_peer` explicitly on named clients — never rely on defaults.

## API Key Management

- API keys for example and example are stored in the database in **encrypted** JSONB columns (`app_key`, `secret_key`) — never in environment variables for per-user keys.
- Application-level (system-wide) API keys live in environment variables (`APP_KOREA_INVESTMENT_KEY`, etc.) — never hardcoded in PHP files.
- Decryption logic lives in a dedicated `Service/{Provider}/ApiKeyService` class — Controllers and Handlers never decrypt directly.
- Never log decrypted API key values — log only the masked key prefix (first 4 characters + `****`).
- Use `#[Sensitive]` on DTO properties that carry API keys or secrets.

## Access Token Lifecycle (example OAuth2)

- example access tokens are obtained via the securities OAuth2 flow and stored in Redis with a TTL matching the token's `expires_in` value.
- Token refresh is handled in the `EventSubscriber` layer — not in Services or Controllers.
- Never cache tokens in the PHP session — Redis is the only allowed token store.
- Revoke tokens on logout via a Messenger Command dispatched asynchronously.

## Response Persistence Pattern

API responses from financial/property providers are persisted to the database as-is in their raw JSON form:

1. Fetch response via HttpClient in a `MessageCommandHandler`.
2. Deserialize via Symfony Serializer into a provider-specific DTO.
3. Persist the raw payload into the matching `Entity` (JSON/JSONB column).
4. Dispatch a `MessageEvent` to trigger downstream processing.

Never transform or aggregate provider data inside the same handler that fetches it — keep fetch and transform separate.

## Error Handling

- Catch `Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface` for network failures.
- Catch `Symfony\Contracts\HttpClient\Exception\HttpExceptionInterface` for 4xx/5xx responses.
- On transient failures (503, timeout), re-throw as a `\RuntimeException` — the RabbitMQ transport will retry up to the configured `max_retries`.
- On permanent failures (401, 403), dispatch a `MessageEvent` to notify the owning user via Symfony Notifier — do not retry.
- Never swallow exceptions silently in provider integration code.

## Holiday & Business Day Handling

- Use `azuyalabs/yasumi` for Korean holiday calculation — never hardcode holiday dates.
- example's `/uapi/domestic-stock/v1/quotations/chk-holiday` endpoint is the authoritative source for market holidays — sync via Scheduler, store results in `ChkHoliday` entity.
- Business-day checks must consult both Yasumi and the `ChkHoliday` entity — either source can identify a non-trading day.

## WebSocket (Ratchet/Pawl)

- WebSocket connections use `ratchet/pawl` for example real-time data streams.
- WebSocket client code lives in `app/src/Service/Providers/Finance/` — not in Controllers or Handlers.
- Never open a WebSocket connection inside a synchronous HTTP request cycle — always dispatch a Command and let the async worker manage the connection.
- WebSocket state (connection handle, subscription list) must be stored in Redis — not in PHP memory or a static property.

## Rate Limiting Awareness

- example REST API has per-second and per-day rate limits — respect them via Symfony Lock (`symfony/lock`) before dispatching consecutive HTTP requests.
- Use a sliding window lock key per API endpoint: `lock_korea_investment_{endpoint_tr_id}`.
- example REST API enforces per-minute and per-second limits — use the same locking pattern.
- Never batch API calls in a tight loop without a lock-guarded delay strategy.

## Scheduler Integration

- Provider data sync tasks (market data, holiday list, coin tickers) are defined as `#[AsPeriodicTask]` classes in `app/src/Scheduler/Providers/{Provider}/`.
- Each task class is annotated with `#[AsPeriodicTask(frequency: '...', jitter: N)]` — one class per recurring task.
- Scheduler tasks dispatch MessageCommands via `MessageBusInterface` — they do not call Services or Repositories directly.
- Market-hours-sensitive tasks must check `ChkHoliday` before executing — guard inside the `MessageCommandHandler`, not in the Scheduler class.
