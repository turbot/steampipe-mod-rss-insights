mod "rss_insights" {
  # hub metadata
  title         = "RSS Insights"
  description   = "Create dashboards and reports for your RSS resources using Steampipe."
  color         = "#FF9900"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/rss-insights.svg"
  categories    = ["rss", "dashboard"]

  opengraph {
    title       = "Steampipe Mod for RSS Insights"
    description = "Create dashboards and reports for your RSS resources using Steampipe."
    image       = "/images/mods/turbot/rss-insights-social-graphic.png"
  }

}