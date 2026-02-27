---
layout: page
title: Matrix Helm Charts
---

**Note:** I am actively testing each helm chart and plan to make `1.0.0` releases only after each have been tested / considered ready. For now, `ntfy`, `matrix-appservice-irc` and `mautrix-telegram` have been confirmed tested and working, hence `0.9.X` versions, but are due a `1.0.0` after further testing of different configurations / deployments.

A collection of helm charts to deploy services alongside Matrix, with example `values.yaml` files, initially focused on [ESS Community](https://github.com/element-hq/ess-helm) but should work with any Matrix deployment.

## Components

| Component | Helm Chart Version | App Version | Repository | Description |
| --- | --- | --- | --- | --- |
| `ntfy` | `0.9.5` | `v2.17.0` | [binwiederhier/ntfy](https://github.com/binwiederhier/ntfy) | HTTP-based pub-sub notification service. Use to provide Matrix push notifications on Android without Google. |
| `matrix-appservice-irc` | `0.9.12` | `release-4.0.0` | [matrix-org/matrix-appservice-irc](https://github.com/matrix-org/matrix-appservice-irc) | IRC bridge for Matrix. |
| `mautrix-telegram` | `0.9.0` | `v0.15.3` | [mautrix/telegram](https://github.com/mautrix/telegram) | A Matrix-Telegram hybrid puppeting/relaybot bridge. |
| `mautrix-googlechat` | `0.1.0` | `v0.5.2` | [mautrix/googlechat](https://github.com/mautrix/googlechat) | A Matrix-Google Chat puppeting bridge. |
| `mautrix-whatsapp` | `0.1.0` | `v26.02` | [mautrix/whatsapp](https://github.com/mautrix/whatsapp) | A Matrix-WhatsApp puppeting bridge based on [whatsmeow](https://github.com/tulir/whatsmeow). |
| `mautrix-discord` | `0.1.0` | `v0.7.6` | [mautrix/discord](https://github.com/mautrix/discord) | A Matrix-Discord puppeting bridge based on [discordgo](https://github.com/bwmarrin/discordgo). |
| `mautrix-slack` | `0.1.0` | `v26.02` | [mautrix/slack](https://github.com/mautrix/slack) | A Matrix-Slack puppeting bridge based on [slack-go](https://github.com/slack-go/slack). |
| `mautrix-gmessages` | `0.1.0` | `v26.02` | [mautrix/gmessages](https://github.com/mautrix/gmessages) | A Matrix-Google Messages puppeting bridge. |
| `mautrix-gvoice` | `0.1.0` | `v25.11` | [mautrix/gvoice](https://github.com/mautrix/gvoice) | A Matrix-Google Voice puppeting bridge. |
| `mautrix-signal` | `0.1.0` | `v26.02` | [mautrix/signal](https://github.com/mautrix/signal) | A Matrix-Signal puppeting bridge. |
| `mautrix-meta` | `0.1.0` | `v26.02` | [mautrix/meta](https://github.com/mautrix/meta) | A Matrix-Facebook Messenger and Instagram DM puppeting bridge. |
| `mautrix-twitter` | `0.1.0` | `v25.11` | [mautrix/twitter](https://github.com/mautrix/twitter) | A Matrix-Twitter DM puppeting bridge. |
| `mautrix-bluesky` | `0.1.0` | `v25.10` | [mautrix/bluesky](https://github.com/mautrix/bluesky) | A Matrix-Bluesky DM puppeting bridge. |
| `mautrix-linkedin` | `0.1.0` | `v26.02` | [mautrix/linkedin](https://github.com/mautrix/linkedin) | A Matrix-LinkedIn puppeting bridge. |
| `mautrix-zulip` | `0.1.0` | `v25.11` | [mautrix/zulip](https://github.com/mautrix/zulip) | A Matrix-Zulip puppeting bridge. |
