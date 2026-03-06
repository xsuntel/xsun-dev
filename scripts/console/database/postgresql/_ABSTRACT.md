# Console Commands

## PostgreSQL

### Connect

* CLI

```bash
[root@localhost] sudo -i -u postgres
[sudo] password for user: {password}

postgres@localhost:~$ psql
psql (xx.y)
Type "help" for help.

postgres=#

postgres=# \q

```

### Database

* Delete

```bash
postgres=# \l

postgres=# drop database {name}
```

* Rename

```bash
postgres=# \l

postgres=# ALTER DATABASE {old_name} RENAME TO {new_name};
```
