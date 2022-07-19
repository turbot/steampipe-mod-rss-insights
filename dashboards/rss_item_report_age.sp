dashboard "rss_item_age_report" {

  title         = "RSS Item Age Report"
  documentation = file("./dashboards/docs/rss_item_report_age.md")

  tags = merge(local.rss_common_tags, {
    type     = "Report"
    category = "Age"
  })
  
  input "feed_link" {
    title       = "Enter a feed link:"
    width       = 4
    type        = "text"
    placeholder = "https://example.com/feed/"
  }

  container {

    card {
      width = 2
      query = query.rss_item_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    card {
      type  = "info"
      width = 2
      query   = query.rss_item_24_hours_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    card {
      type  = "info"
      width = 2
      query   = query.rss_item_30_days_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    card {
      type  = "info"
      width = 2
      query   = query.rss_item_30_90_days_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    card {
      width = 2
      type  = "info"
      query   = query.rss_item_90_365_days_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    card {
      width = 2
      type  = "info"
      query   = query.rss_item_1_year_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

  }

  table {
    query = query.rss_item_age_table
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

}

query "rss_item_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      rss_item
    where
      feed_link = $1 and published > now() - '1 days' :: interval;
  EOQ

  param "feed_link" {}
}

query "rss_item_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      rss_item
    where
      feed_link = $1 and published between symmetric now() - '1 days' :: interval
      and now() - '30 days' :: interval;
  EOQ

  param "feed_link" {}
}

query "rss_item_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      rss_item
    where
      feed_link = $1 and published between symmetric now() - '30 days' :: interval
      and now() - '90 days' :: interval;
  EOQ

  param "feed_link" {}
}

query "rss_item_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      rss_item
    where
      feed_link = $1 and published between symmetric (now() - '90 days'::interval)
      and (now() - '365 days'::interval);
  EOQ

  param "feed_link" {}
}

query "rss_item_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      rss_item
    where
      feed_link = $1 and published <= now() - '1 year' :: interval;
  EOQ

  param "feed_link" {}
}

query "rss_item_age_table" {
  sql = <<-EOQ
    select
      title as "Title",
      link as "Link",
      author_email as "Author Email",
      author_name as "Author Name",
      categories as "Categories",
      published as "Published",
      updated as "Updated"
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1;
  EOQ

  param "feed_link" {}
}