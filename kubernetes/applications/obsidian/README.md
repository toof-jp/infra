# Obsidian Sync → Git Bridge

Always-on Obsidian (linuxserver/obsidian, KasmVNC GUI) running in the cluster. It joins Obsidian Sync as one more device and pushes the vault to GitHub via the obsidian-git plugin on a schedule.

```text
Mobile/Mac ⇄ Obsidian Sync ⇄ this pod → git push → github.com/toof-jp/non-demagogue
```

The git side is a read mirror. Nothing writes back into the vault through git; the cluster's `obsidian-msp` reader keeps pulling the repo as before.

## Security

`https://obsidian-gui.toof.jp` is a full-access GUI to the vault (and to the Obsidian Sync account). It MUST stay behind Cloudflare Access.

- The Access application (`obsidian_gui` in `terraform/access.tf`, GitHub IdP, `allow-github-toof` policy) is part of the same change set as the Ingress.
- Do not deploy the Ingress without the Access application applied. Terraform auto-applies on merge to main, but verify before first use: opening `https://obsidian-gui.toof.jp` in a private browser window must show the Cloudflare Access GitHub login, not the KasmVNC screen.

## Deploy

ArgoCD picks up this directory via the ApplicationSet entry (`obsidian`). Merging to main deploys everything except the two manual steps below (SSH key secret, in-GUI setup).

## SSH Deploy Key (manual, before first git push)

1. Generate a key pair and grab known_hosts:

   ```sh
   ssh-keygen -t ed25519 -f obsidian-git -N "" -C "obsidian-k8s"
   ssh-keyscan github.com > known_hosts
   ```

2. GitHub → `toof-jp/non-demagogue` → Settings → Deploy keys → Add deploy key:
   - Title: `obsidian-k8s`
   - Key: contents of `obsidian-git.pub`
   - **Allow write access: ON**

3. 1Password (vault `infra`): create an item named `obsidian` (Secure Note), add a section `git-ssh` with two multiline text fields:
   - `id_ed25519`: contents of the private key file `obsidian-git`
   - `known_hosts`: contents of `known_hosts`

   The ExternalSecret resolves `op://infra/obsidian/git-ssh/<field>` and mounts the result at `/config/.ssh` (read-only, root-owned, group `1000` readable — OpenSSH accepts this because the file is not owned by the running user).

4. Delete the local key files.

## First-Time Setup (manual, via the GUI)

1. Open `https://obsidian-gui.toof.jp` (through Cloudflare Access).
2. In Obsidian, create the vault at `/config/vaults/main`, log in to Obsidian Sync, connect to the remote vault, and wait for the initial sync to finish.
3. Open a terminal in the KasmVNC session:

   ```sh
   cd /config/vaults/main
   git init
   git remote add origin git@github.com:toof-jp/non-demagogue.git
   git config user.name "obsidian-k8s"
   git config user.email "obsidian-k8s@toof.jp"
   git fetch origin
   git checkout -B main origin/main 2>/dev/null || git checkout -b main
   ```

   (If the vault content should replace the existing repo history instead of merging onto it, skip the fetch/checkout and just commit-push from the plugin.)

4. Create `.gitignore` in the vault root:

   ```text
   .obsidian/workspace.json
   .obsidian/workspace-mobile.json
   .obsidian/plugins/*/data.json
   .trash/
   ```

5. Install the community plugin **Git** (obsidian-git) and configure:
   - Auto commit-and-sync interval: 10 minutes
   - Pull before push: ON

## Restart Resilience Check

```sh
kubectl rollout restart deploy/obsidian -n obsidian
kubectl rollout status deploy/obsidian -n obsidian
```

Then in the GUI: Obsidian should reopen the vault automatically (state lives on the `obsidian-config` PVC), Obsidian Sync should reconnect on its own, and within one interval the Git plugin should commit-and-sync again — verify with `git log -1` in the vault or a fresh commit on GitHub. The SSH key survives restarts because it comes from the Secret mount, not the PVC.

## Notes

- `DOCKER_MODS=linuxserver/mods:universal-package-install` + `INSTALL_PACKAGES=git|openssh-client` installs git/ssh at container start; first boot takes a bit longer.
- `seccompProfile: Unconfined` is required for Electron's sandbox inside the container. If Obsidian still fails to start, the fallback is adding the `SYS_ADMIN` capability instead.
- `strategy: Recreate` is required because the config volume is a ReadWriteOnce PVC.
