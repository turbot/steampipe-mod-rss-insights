mod "rss_insights" {
  # hub metadata
  title         = "RSS Insights"
  description   = "Create dashboards and reports for your RSS channels using Steampipe."
  color         = "#FFA500"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/rss-insights.svg"
  categories    = ["rss", "dashboard"]

  opengraph {
    title       = "Steampipe Mod for RSS Insights"
    description = "Create dashboards and reports for your RSS channels using Steampipe."
    image       = "/images/mods/turbot/rss-insights-social-graphic.png"
  }

}