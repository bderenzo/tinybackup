# Tinybackup

Tinybackup is a tiny bash wrapper powered by [Kopia](https://kopia.io), making backups simple and easily scriptable.
It handles repository setup, retention policies, ignore rules and pre/post hooks from a minimal config file.

## Features

* Easy configuration and usage
* Tiny, single-file bash script
* Automatic repository initialization and connection
* Several supported repository backends: local, S3, SFTP, rclone
* Retention policies and ignore rules
* Backup hooks (e.g., stop services, dump databases)
* Backup mount for content browsing (via FUSE)
* Integrated Kopia web-ui or server access

## Requirements

Tinybackup requires [Kopia](https://kopia.io/docs/installation/). Install it via: 
* your package manager, if Kopia is packaged for your distribution,
* the included script, which installs the latest static binary:
```bash
./install-kopia
```

## Installation

No installation needed: just run `./tinybackup` from the cloned directory.  
To call it from anywhere, symlink it into your `PATH` (config stays in the cloned `conf.d/`):

```bash
ln -s "$(pwd -P)/tinybackup" /usr/local/bin/tinybackup
```

For bash completion (requires the bash-completion package), symlink it too:

```bash
mkdir -p /usr/local/share/bash-completion/completions
ln -s "$(pwd -P)/completions/tinybackup.bash" /usr/local/share/bash-completion/completions/tinybackup
```

To uninstall, remove links: 
```bash
rm /usr/local/bin/tinybackup /usr/local/share/bash-completion/completions/tinybackup
```

## Usage

### Configuration

Configure your system backup in `conf.d/${HOSTNAME%%.*}.conf`, for example:

```bash
# Repository configuration
REPO_TYPE='sftp'
SFTP_USER='tiny'
SFTP_HOST='192.168.10.10'
SFTP_KEY='/home/tiny/.ssh/id_ed25519'
SFTP_PATH='/mnt/backup/repo'

# Backup configuration
PRE_BACKUP_HOOK='systemctl stop nginx'
POST_BACKUP_HOOK='systemctl start nginx'
RETENTION_CONFIG=('latest=10' 'daily=7' 'weekly=4')
TO_BACKUP=('/etc' '/var' '/home')
```

> [!IMPORTANT]
> For SFTP, trust the server ECDSA host key once beforehand, as root (see [kopia#2948](https://github.com/kopia/kopia/issues/2948)):
> ```bash
> ssh -o HostKeyAlgorithms=ecdsa-sha2-nistp256 -i /home/tiny/.ssh/id_ed25519 tiny@192.168.10.10 -- exit
> ```

For all available configuration variables and explanation, see provided presets [here](./conf.d).  
To use a specific file, pass it as option: `./tinybackup -c /path/other.conf backup`.

### Execution

The first `backup` creates the repository if missing (local repository directory must exist):

```bash
./tinybackup backup                             # Create a snapshot
./tinybackup list                               # List available snapshots
./tinybackup restore <ID> /restore/path         # Restore a snapshot (ID shown by list) to a directory
./tinybackup restore <ID>/nginx /tmp/nginx.zip  # Restore a sub-directory to a zip archive
```

The repository password is prompted on first connection only.  
For a non-interactive first run (e.g. cron), export `KOPIA_PASSWORD` before executing any command.

> [!WARNING]
> The script re-executes itself as root with `sudo` (set `FORCE_ROOT=false` to disable).

For all other commands (`mount`, `check`, `policy`, `maintenance`, `raw`, `web-ui`, etc.) and options, see:

```bash
./tinybackup --help
```
