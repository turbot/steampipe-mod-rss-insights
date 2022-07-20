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
    type  = "multiselect"
    query = query.rss_item_category
    width = 4
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

  input "author" {
    title = "Select an author:"
    type  = "multiselect"
    query = query.rss_item_author
    width = 4
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

  container {

    chart {
      title = "Items by Category"
      width = 6
      type  = "column"
      query = query.rss_item_by_category
      args  = {
        feed_link = self.input.feed_link.value
    }
    }

    chart {
      title = "Items by Author"
      width = 6
      type  = "column"
      query = query.rss_item_by_author
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
        author = self.input.author.value
    }
    column "Content" {
    wrap = "none"
  }
  }

}

query "rss_item_by_author" {
  sql = <<-EOQ
    select
      regexp_replace(author_name,'<[^>]*>', '','g') as author_name,
      count(*)
    from
      rss_item
    where
      feed_link = $1
    group by
      author_name
    order by
      author_name;
  EOQ

  param "feed_link" {}
}

query "rss_item_by_category" {
  sql = <<-EOQ
    select
      category,
      count(*)
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1
    group by
      category
    order by
      count desc;
  EOQ

  param "feed_link" {}
}

query "rss_item_category" {
  sql = <<-EOQ
    with category as (
    select
      'All' as label,
      string_agg(distinct category,E',') as value
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

query "rss_item_author" {
  sql = <<-EOQ
    with regex_author as(
     select
      regexp_replace(author_name,'<[^>]*>', '','g') as author_name
    from
      rss_item
    where
      feed_link = $1
    ),
    author as (
    select
      'All' as label,
      string_agg(distinct author_name,E',') as value
    from
      regex_author
    union (
    select
      distinct author_name label,
      author_name as value
    from
      regex_author
    order by
      author_name))
    select
      label,
      value
    from
      author
    order by label;
  EOQ

  param "feed_link" {}
}

query "rss_item_table" {
  sql = <<-EOQ
    select
      title as "Title",
      link as "Link",
      regexp_replace(author_name,'<[^>]*>', '','g') as "Author Name",
      author_email as "Author Email",
      categories as "Categories",
      published as "Published",
      updated as "Updated"
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1 and category in (select unnest (string_to_array($2, ',')::text[]))
      and regexp_replace(author_name,'<[^>]*>', '','g') in (select unnest (string_to_array($3, ',')::text[]))
    order by
      published desc;
  EOQ

  param "feed_link" {}
  param "category" {}
  param "author" {}
}