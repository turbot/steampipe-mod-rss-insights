---
repository: "https://github.com/turbot/steampipe-mod-rss-insights"
---

# RSS Insights Mod

Create dashboards and reports for your RSS Channels using Steampipe.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-rss-insights/main/docs/images/rss_reader_dashboard.png" width="50%" type="thumbnail"/>

## Overview

Dashboard can help answer questions like:

- What is the channel information for each feed?
- How many items were published for each category?
- How many items were published by each author?
- How many items were published by month or year?
- What items were published?

## References

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/rss_insights/dashboards)**

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the RSS plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install RSS
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-rss-insights.git
cd steampipe-mod-rss-insights
```

### Usage

Before running any dashboards, it's required to add feed links in the config file:

```sh
~/.steampipe/config/rss.spc
```

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194. From here, you can view dashboards and reports.

### Credentials

No Credential is required.

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional dashboards or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-aws-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [RSS Insights Mod](https://github.com/turbot/steampipe-mod-rss-insights/labels/help%20wanted)
