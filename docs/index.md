---
layout: page
title: Matrix Helm Charts
---

A collection of helm charts to deploy services alongside Matrix, with example `values.yaml` files, initially focused on [ESS Community](https://github.com/element-hq/ess-helm) but should work with any Matrix deployment.

## Components

| Component | Repository | Description |
| --- | --- | --- |
| `ntfy` | [binwiederhier/ntfy](https://github.com/binwiederhier/ntfy) | HTTP-based pub-sub notification service. Use to provide Matrix push notifications on Android without Google. |
| `matrix-appservice-irc` | [matrix-org/matrix-appservice-irc](https://github.com/matrix-org/matrix-appservice-irc) | IRC bridge for Matrix. |
| `mautrix-telegram` | [mautrix/telegram](https://github.com/mautrix/telegram) | A Matrix-Telegram hybrid puppeting/relaybot bridge. |
| `mautrix-googlechat` | [mautrix/googlechat](https://github.com/mautrix/googlechat) | A Matrix-Google Chat puppeting bridge. |
| `mautrix-whatsapp` | [mautrix/whatsapp](https://github.com/mautrix/whatsapp) | A Matrix-WhatsApp puppeting bridge based on [whatsmeow](https://github.com/tulir/whatsmeow). |
| `mautrix-discord` | [mautrix/discord](https://github.com/mautrix/discord) | A Matrix-Discord puppeting bridge based on [discordgo](https://github.com/bwmarrin/discordgo). |
| `mautrix-slack` | [mautrix/slack](https://github.com/mautrix/slack) | A Matrix-Slack puppeting bridge based on [slack-go](https://github.com/slack-go/slack). |
| `mautrix-gmessages` | [mautrix/gmessages](https://github.com/mautrix/gmessages) | A Matrix-Google Messages puppeting bridge. |
| `mautrix-gvoice` | [mautrix/gvoice](https://github.com/mautrix/gvoice) | A Matrix-Google Voice puppeting bridge. |
| `mautrix-signal` | [mautrix/signal](https://github.com/mautrix/signal) | A Matrix-Signal puppeting bridge. |
| `mautrix-meta` | [mautrix/meta](https://github.com/mautrix/meta) | A Matrix-Facebook Messenger and Instagram DM puppeting bridge. |
| `mautrix-twitter` | [mautrix/twitter](https://github.com/mautrix/twitter) | A Matrix-Twitter DM puppeting bridge. |
| `mautrix-bluesky` | [mautrix/bluesky](https://github.com/mautrix/bluesky) | A Matrix-Bluesky DM puppeting bridge. |
| `mautrix-linkedin` | [mautrix/linkedin](https://github.com/mautrix/linkedin) | A Matrix-LinkedIn puppeting bridge. |
| `mautrix-zulip` | [mautrix/zulip](https://github.com/mautrix/zulip) | A Matrix-Zulip puppeting bridge. |
