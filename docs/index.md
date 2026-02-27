---
layout: page
title: Matrix Helm Charts
---

A collection of helm charts to deploy services alongside Matrix, with example `values.yaml` files, initially focused on [ESS Community](https://github.com/element-hq/ess-helm) but should work with any Matrix deployment.

## Components

- `ntfy`: ntfy (pronounced "notify") is a simple HTTP-based pub-sub notification service. See [binwiederhier/ntfy](https://github.com/binwiederhier/ntfy) for details.
- `matrix-appservice-irc`: This is an IRC bridge for Matrix. See [matrix-org/matrix-appservice-irc](https://github.com/matrix-org/matrix-appservice-irc) for details.
- `mautrix-telegram`: A Matrix-Telegram hybrid puppeting/relaybot bridge. See [mautrix/telegram](https://github.com/mautrix/telegram) for details.
- `mautrix-googlechat`: A Matrix-Google Chat puppeting bridge. See [mautrix/googlechat](https://github.com/mautrix/googlechat) for details.
- `mautrix-whatsapp`: A Matrix-WhatsApp puppeting bridge. See [mautrix/whatsapp](https://github.com/mautrix/whatsapp) for details.
- `mautrix-discord`: A Matrix-Discord puppeting bridge. See [mautrix/discord](https://github.com/mautrix/discord) for details.
