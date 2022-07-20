dashboard "rss_item_report" {

  title         = "RSS Item Report"
  documentation = file("./dashboards/docs/rss_item_report.md")

  tags = merge(local.rss_common_tags, {
  type = "Report"
  })

  input "feed_link" {
    title       = "Enter a feed link:"
    width       = 4
    type        = "text"
    placeholder = "https://example.com/feed/"
  }

  input "category" {
    title = "Select a category:"
    query = query.rss_item_category
    width = 4
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

  container {

    card {
      width = 2
      query = query.rss_item_count
      args  = {
        feed_link = self.input.feed_link.value
    }
    }
  }
  table {
    query = query.rss_item_table
    args  = {
        feed_link = self.input.feed_link.value
        category = self.input.category.value
    }
  }

}

query "rss_item_category" {
  sql = <<-EOQ
    with category as (
    select
      'All' as label,
      string_agg(distinct category,E'\',\'') as value
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1
    union (
    select
      distinct category label,
      category as value
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1
    order by
      category))
    select
      label,
      value
    from
      category
    order by label;
  EOQ

  param "feed_link" {}
}

query "rss_item_count" {
  sql = <<-EOQ
    select
      count(*) as "Items"
    from
      rss_item
    where
      feed_link = $1;
  EOQ

  param "feed_link" {}
}

query "rss_item_table" {
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
      feed_link = $1 and category in ($2);
  EOQ

  param "feed_link" {}
  param "category" {}
}