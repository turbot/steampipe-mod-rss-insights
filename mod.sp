mod "rss_insights" {
  # hub metadata
  title         = "RSS Insights"
  description   = "Create dashboards and reports for your RSS resources using Steampipe."
  color         = "#FF9900"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/aws-insights.svg"
  categories    = ["rss", "dashboard"]

  opengraph {
    title       = "Steampipe Mod for AWS Insights"
    description = "Create dashboards and reports for your RSS resources using Steampipe."
    image       = "/images/mods/turbot/aws-insights-social-graphic.png"
  }

}