# Vault backup (macOS)

A one-way mirror from `~/Documents/vaults/` to a dedicated server directory. All files (including images) are copied, except `.obsidian` directories and `.DS_Store` files. Previously copied `.DS_Store` files are deleted from the destination on the next sync. Deleting a local file deletes its server copy on the next successful sync. The watcher batches changes for 10 seconds; a separate 5-minute job catches changes made while disconnected or asleep. Both run at login under launchd. The script stays in this repository; launchd points to it directly.

**Important:** The destination is a *mirror*, not a versioned backup. Do not edit it on the server or share the same destination with another laptop: `--delete` will remove remote-only files. Give each laptop its own destination subdirectory if you use more than one. The script never creates the remote directory, to avoid accidentally mirroring into the wrong location.

## One-time setup on a new laptop

1. For the optional background watcher, install `fswatch` with `brew install fswatch`. Manual sync needs only macOS's built-in `/usr/bin/rsync`.
2. Create an SSH key if you don't have one for this server: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_vault_backup`. For fully unattended use, choose an empty passphrase **or** add the passphrase-protected key to the macOS SSH agent/Keychain and confirm it works after login. Restrict access to the private key (`chmod 600 ~/.ssh/id_ed25519_vault_backup`). Install the *public* key on the server in the account's `~/.ssh/authorized_keys` (mode 600); its `~/.ssh` should be mode 700.
3. Add this SSH alias in `~/.ssh/config` (mode 600), replacing the host and user locally:

   ```sshconfig
   Host vault-backup
       HostName <server-address>
       User <server-user>
       IdentityFile ~/.ssh/id_ed25519_vault_backup
       IdentitiesOnly yes
       BatchMode yes
   ```

   The server address and username stay out of this repository. No Vaultwarden credential or unlocked `bw` session is needed by launchd. Store a recovery copy of the SSH key securely if desired, but **never** put the private key in this repo.
4. Create a dedicated server directory (after reviewing the path):

   ```sh
   ssh vault-backup 'mkdir -p /gympool/data/vaults'
   ssh -o BatchMode=yes vault-backup 'test -w /gympool/data/vaults' && echo 'SSH and destination OK'
   ```

5. Configure the destination locally:

   ```sh
   mkdir -p ~/.config/vault-sync
   cp ~/.dotfiles/scripts/vault-sync/config.example ~/.config/vault-sync/config
   chmod 600 ~/.config/vault-sync/config
   ```

   Edit `SSH_ALIAS`, `REMOTE_PATH`, or `SOURCE_DIR` there as needed. Use an absolute `REMOTE_PATH` without spaces or shell punctuation. This config is outside git. If another laptop uses the same server, use a separate directory such as `/gympool/data/vaults/laptop-name` for each laptop.
6. Preview **before enabling deletion** (uses the config's default values; adjust the alias/path if changed):

   ```sh
   /usr/bin/rsync -azn --delete --exclude='.obsidian/' --filter='-s .DS_Store' \
     -e 'ssh -o BatchMode=yes -o ConnectTimeout=5' \
     ~/Documents/vaults/ vault-backup:/gympool/data/vaults/
   ```

7. After checking the preview: `~/.dotfiles/scripts/vault-sync/install-mac.sh`. This starts the watcher immediately and installs a periodic retry. The scripts use SSH batch mode and a 5-second connection timeout, so an unavailable server produces no prompts or log spam.

## Operation

- Log: `~/Library/Logs/vault-sync.log` (timestamped `SUCCESS` or `ERROR` per attempted rsync; offline checks produce no entries).
- Run manually: `~/.dotfiles/scripts/vault-sync/sync.sh`. It prints changed paths (or `No changes`), completion, and errors; results are also logged. Add `--quiet` for background use.
- Inspect jobs: `launchctl print gui/$UID/local.vault-sync.watch` and `launchctl print gui/$UID/local.vault-sync.retry`.
- Reinstall after moving the dotfiles checkout: rerun `install-mac.sh`.
- Stop: `launchctl bootout gui/$UID ~/Library/LaunchAgents/local.vault-sync.watch.plist` and likewise for `local.vault-sync.retry.plist`.

The watcher and periodic job use a shared lock to avoid simultaneous rsync runs. An offline SSH check is intentionally silent; if SSH succeeds but rsync fails, the error is logged. The launchd jobs run in your logged-in user session, not while the laptop is shut down or logged out.
