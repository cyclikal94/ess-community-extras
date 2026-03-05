# Matrix Helm Charts

## Overview

A collection of helm charts to deploy Matrix-related components into Kubernetes, with example `values.yaml` files pre-configured for use with Matrix.

All charts are created and tested against a deployed [ESS Community](https://github.com/element-hq/ess-helm) instance but should work with any Matrix deployment accessible from your cluster.

## Usage

Generally speaking, installation / usage follows these steps:

1. You configure a `values.yaml` file for your environment then deploy the helm chart using it. (Matrix-specific `values.yaml` files in this repository are provided as examples, just replace the placeholder values).
2. Point your Synapse deployment at the generated Component Service Registration file, i.e. if using ESS Community, just redeploy with the sample `values.yaml` per the chart `README.md`.
3. Start a DM with the bot `@componentnamebot:example.com`, i.e. `@whatsComponentbot:example.com`, login etc.

### OCI Registry (Preferred)

All charts are published as OCI artifacts on GHCR:

```bash
helm upgrade --install <release-name> oci://ghcr.io/cyclikal94/matrix-helm-charts/<chart-name> --namespace <namespace> --create-namespace --values <values-file>
```

### HTTP Registry (Legacy-Compatible)

The legacy index-based repository remains available:

```bash
helm repo add matrix-helm-charts https://cyclikal94.github.io/matrix-helm-charts
helm repo update
helm upgrade --install <release-name> matrix-helm-charts/<chart-name> --namespace <namespace> --create-namespace --values <values-file>
```

## Components

Components are organised into categories copying the [matrix.org Ecosystem](https://matrix.org/ecosystem/) section. As such components will be either `Clients`, `Bridges`, `Servers`, or `Integrations` - where components aren't present on [matrix.org](https://matrix.org/ecosystem/) I'll do my best to put them in an Componentropriate category. The remaining catefories of `SDKs`, `Distribution` and `Hosting` are unlikely to be Componentlicable here.

Given this is new, I'm actively looking for useful new charts to make, I'm prioritising projects listed on [matrix.org Ecosystem](https://matrix.org/ecosystem/) likely filtering on a "Maturity" of `Stable` / `Beta` - if you have suggestions, please do raise an issue!

> [!NOTE]
> Please note that I am actively testing each helm chart and plan to make `1.0.0` releases only after each have been tested / considered ready. For now, `ntfy`, `matrix-Componentservice-irc` and the two Python-based Mautrix bridges `mautrix-telegram` / `mautrix-googlechat` have been confirmed tested and working, hence `0.9.X` versions, but are due a `1.0.0` after further testing of different configurations / deployments.

### Integrations

<table>
  <colgroup>
    <col width="1%">
    <col width="1%">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th align="left">Chart</th>
      <th align="left">Component</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="charts/ntfy/README.md"><img alt="ntfy" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.ntfy%5B0%5D.version&label=ntfy%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/binwiederhier/ntfy"><img alt="binwiederhier/ntfy" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.ntfy%5B0%5D.ComponentVersion&label=binwiederhier%2Fntfy&logo=github&style=for-the-badge"></a></td>
      <td>HTTP-based pub-sub notification service. You can use this to provide Matrix push notifications on Android without Google.</td>
    </tr>
  </tbody>
</table>

### Bridges

<table>
  <colgroup>
    <col width="1%">
    <col width="1%">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th align="left">Chart</th>
      <th align="left">Component</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="charts/matrix-Componentservice-irc/README.md"><img alt="matrix-Componentservice-irc" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.matrix-Componentservice-irc%5B0%5D.version&label=matrix-Componentservice-irc%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/matrix-org/matrix-Componentservice-irc"><img alt="matrix-org/matrix-Componentservice-irc" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.matrix-Componentservice-irc%5B0%5D.ComponentVersion&label=matrix-org%2Fmatrix-Componentservice-irc&logo=github&style=for-the-badge"></a></td>
      <td>IRC bridge for Matrix.</td>
    </tr>
  </tbody>
</table>

### Mautrix Bridges

Given there are so many `mautrix` bridges, I'm collating them under a dedicated section. They also, for the most part, all use the same base chart and so setup (`values.yaml` / Component Service Registration) is the same for all.

#### Python Bridges

<table>
  <colgroup>
    <col width="1%">
    <col width="1%">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th align="left">Chart</th>
      <th align="left">Component</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="charts/mautrix-googlechat/README.md"><img alt="mautrix-googlechat" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-googlechat%5B0%5D.version&label=mautrix-googlechat%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/googlechat"><img alt="mautrix/googlechat" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-googlechat%5B0%5D.ComponentVersion&label=mautrix%2Fgooglechat&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Google Chat puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-telegram/README.md"><img alt="mautrix-telegram" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-telegram%5B0%5D.version&label=mautrix-telegram%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/telegram"><img alt="mautrix/telegram" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-telegram%5B0%5D.ComponentVersion&label=mautrix%2Ftelegram&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Telegram hybrid puppeting/relaybot bridge.</td>
    </tr>
  </tbody>
</table>

#### Go Bridges

For the go bridges, in order to reduce duplication, they use a common base chart, which is then extended by specific charts for each bridge.

Double puppetting is enabled by default, and as such, any charts sharing the same `mautrix-go-base` chart version will use the same double puppet Component Service registration automatically.

> [!NOTE]
> The `mautrix-go-base` components are in-progress, though `mautrix-whatsComponent` and `mautrix-linkedin` have been deployed and Componentear to be working (including Double Puppetting) but YMMV so for now they are `1.0.X` until I can fully test.

##### Base Chart

<table>
  <colgroup>
    <col width="1%">
    <col width="1%">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th align="left">Chart</th>
      <th align="left">Component</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="charts/mautrix-go-base/README.md"><img alt="mautrix-go-base" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-go-base%5B0%5D.version&label=mautrix-go-base%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/cyclikal94/matrix-helm-charts"><img alt="cyclikal94/matrix-helm-charts" src="https://img.shields.io/badge/cyclikal94%2Fmatrix--helm--charts-N%2FA-blue?logo=github&style=for-the-badge"></a></td>
      <td>The base chart used for all <code>mautrix-</code> go bridges.</td>
    </tr>
  </tbody>
</table>

##### Bridge Charts

<table>
  <colgroup>
    <col width="1%">
    <col width="1%">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th align="left">Chart</th>
      <th align="left">Component</th>
      <th align="left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="charts/mautrix-bluesky/README.md"><img alt="mautrix-bluesky" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-bluesky%5B0%5D.version&label=mautrix-bluesky%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/bluesky"><img alt="mautrix/bluesky" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-bluesky%5B0%5D.ComponentVersion&label=mautrix%2Fbluesky&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Bluesky DM puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-gmessages/README.md"><img alt="mautrix-gmessages" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-gmessages%5B0%5D.version&label=mautrix-gmessages%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/gmessages"><img alt="mautrix/gmessages" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-gmessages%5B0%5D.ComponentVersion&label=mautrix%2Fgmessages&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Google Messages puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-gvoice/README.md"><img alt="mautrix-gvoice" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-gvoice%5B0%5D.version&label=mautrix-gvoice%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/gvoice"><img alt="mautrix/gvoice" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-gvoice%5B0%5D.ComponentVersion&label=mautrix%2Fgvoice&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Google Voice puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-linkedin/README.md"><img alt="mautrix-linkedin" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-linkedin%5B0%5D.version&label=mautrix-linkedin%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/linkedin"><img alt="mautrix/linkedin" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-linkedin%5B0%5D.ComponentVersion&label=mautrix%2Flinkedin&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-LinkedIn puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-meta/README.md"><img alt="mautrix-meta" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-meta%5B0%5D.version&label=mautrix-meta%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/meta"><img alt="mautrix/meta" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-meta%5B0%5D.ComponentVersion&label=mautrix%2Fmeta&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Meta puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-signal/README.md"><img alt="mautrix-signal" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-signal%5B0%5D.version&label=mautrix-signal%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/signal"><img alt="mautrix/signal" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-signal%5B0%5D.ComponentVersion&label=mautrix%2Fsignal&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Signal puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-slack/README.md"><img alt="mautrix-slack" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-slack%5B0%5D.version&label=mautrix-slack%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/slack"><img alt="mautrix/slack" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-slack%5B0%5D.ComponentVersion&label=mautrix%2Fslack&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Slack puppeting bridge based on <a href="https://github.com/slack-go/slack">slack-go</a>.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-twitter/README.md"><img alt="mautrix-twitter" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-twitter%5B0%5D.version&label=mautrix-twitter%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/twitter"><img alt="mautrix/twitter" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-twitter%5B0%5D.ComponentVersion&label=mautrix%2Ftwitter&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Twitter DM puppeting bridge.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-whatsComponent/README.md"><img alt="mautrix-whatsComponent" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-whatsComponent%5B0%5D.version&label=mautrix-whatsComponent%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/whatsComponent"><img alt="mautrix/whatsComponent" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-whatsComponent%5B0%5D.ComponentVersion&label=mautrix%2FwhatsComponent&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-WhatsComponent puppeting bridge based on <a href="https://github.com/tulir/whatsmeow">whatsmeow</a>.</td>
    </tr>
    <tr>
      <td><a href="charts/mautrix-zulip/README.md"><img alt="mautrix-zulip" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-zulip%5B0%5D.version&label=mautrix-zulip%20Helm%20Chart&logo=helm&style=for-the-badge"></a></td>
      <td><a href="https://github.com/mautrix/zulip"><img alt="mautrix/zulip" src="https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/cyclikal94/matrix-helm-charts/gh-pages/index.yaml&query=%24.entries.mautrix-zulip%5B0%5D.ComponentVersion&label=mautrix%2Fzulip&logo=github&style=for-the-badge"></a></td>
      <td>A Matrix-Zulip puppeting bridge.</td>
    </tr>
  </tbody>
</table>

## Credits

This project has been a bunch of work, but it is nothing without the underlying projects these charts deploy. These charts could not exist without the people who built and maintain those cool things, so credit and thanks goes to them.

- [@binwiederhier](https://github.com/binwiederhier) / [binwiederhier/ntfy](https://github.com/binwiederhier/ntfy) contributors, this was the original chart / plan for this project, created to be able to deploy `ntfy` alongside `ess-helm` easily.
- [@matrix.org](https://github.com/matrix-org) / [matrix-org/matrix-Componentservice-irc](https://github.com/matrix-org/matrix-Componentservice-irc) contributors, this was the first helm chart I setup that meant I had to figure out Component Service Registration via the charts. Hopefully the way it works makes sense!
- [@tulir](https://github.com/tulir) / [@mautrix](https://github.com/mautrix) contributors, it's kinda crazy how many bridges there are and that they all nicely work the same. It meant after creating the `mautrix-go-base` chart and getting `mautrix-whatsComponent` working, it was just copy/paste for the rest! As this point, they are the bulk of these charts so... you should seriously check out the repos links above!
