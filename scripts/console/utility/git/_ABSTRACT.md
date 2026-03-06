# Utility - Git

## Config

### Global

* Update default branch

```bash
git config --global user.name "Your Name"
git config --global user.email "you@examle.com"

git config --global init.defaultBranch main
git config --global credential.helper store

git config --global --list
```

### Local

* Update Configuration

```bash
git config --local core.editor vi
git config --local core.autocrlf false
git config --local color.ui true
git config --local diff.ui auto
git config --local format.pretty oneline
git config --local pull.rebase true
git config --local push.default simple

git config --local --list
```

* Reset password

```bash
git config --local --unset credential.helper
```

* Check global configurations

```bash
git config --local credential.helper store
```

#### Branch

* Move

```bash
git branch
git switch {branch_name}
```

* Rename

```bash
git branch
git branch -m {old_branch_name} {new_branch_name}
```

* Delete

```bash
git branch
git branch -d {branch_name}
```

## Tools

* Download files

```bash
./scripts/console/utility/git/pull.sh
```

* Update files

```bash
./scripts/console/utility/git/push.sh
```

* Clear history & Re-initialize

```bash
./scripts/console/utility/git/localhost/clear.sh
```

## Reference

* Git            - [Documents](https://git-scm.com/)
