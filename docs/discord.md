# Discord Terraform Notes

- Invite the bot to the target server before running `terraform import`.
- We only imported the existing guild via `terraform import discord_server.main <server_id>`; other Discord resources are managed purely by Terraform.
