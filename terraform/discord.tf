resource "discord_server" "toof_infra" {
  name = "toof-infra"
}

resource "discord_text_channel" "general" {
  name                     = "notification"
  server_id                = discord_server.toof_infra.id
  sync_perms_with_category = false
}

resource "discord_webhook" "webhook" {
  channel_id = discord_text_channel.general.id
  name       = "notification"
}
