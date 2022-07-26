dashboard "rss_item_report" {

  title         = "RSS Item Report"
  documentation = file("./dashboards/docs/rss_item_report.md")

  tags = merge(local.rss_common_tags, {
  type = "Report"
  })

  input "feed_link" {
    title       = "Select a feed link:"
    width       = 3
    query       = query.rss_feed_link
  }

  input "category" {
    title = "Select a category:"
    type  = "multiselect"
    query = query.rss_item_category
    width = 3
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

  input "author" {
    title = "Select an author:"
    type  = "multiselect"
    query = query.rss_item_author
    width = 3
    args  = {
        feed_link = self.input.feed_link.value
    }
  }

  input "published_month" {
    title = "Select a published month:"
    type  = "multiselect"
    query = query.rss_item_published_month
    width = 3
    args  = {
        feed_link = self.input.feed_link.value
    }
  }
  
  container {

  table {
    title = "Channel"
    type  = "line"
    query = query.rss_channel_table
    width = 3
    args  = {
        feed_link = self.input.feed_link.value
    }
  }
  
  chart {
      title = "Items by Category"
      width = 3
      type  = "donut"
      query = query.rss_item_by_category
      args  = {
        feed_link = self.input.feed_link.value
        category = self.input.category.value
    }
    }
     chart {
      title = "Items by Author"
      width = 3
      type  = "donut"
      query = query.rss_item_by_author
      args  = {
        feed_link = self.input.feed_link.value
        author = self.input.author.value
    }
    }

    chart {
      title = "Items by Published Month" 
      width = 3
      query = query.rss_item_by_published
      args  = {
        feed_link = self.input.feed_link.value
        published_month = self.input.published_month.value
      }
  }
  }

  table {
    query = query.rss_item_table
    args  = {
        feed_link = self.input.feed_link.value
        category = self.input.category.value
        author = self.input.author.value
        published_month = self.input.published_month.value
    }
  }

}

query "rss_feed_link" {
  sql = <<-EOQ
    select
      feed_link as label,
      feed_link as value
    from
      rss_channel
    order by
      feed_link;
  EOQ
}

query "rss_item_category" {
  sql = <<-EOQ
    with categories as (
    select
      distinct category label,
      category as value
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    where
      feed_link = $1
    union 
    select
      '<No category>' label,
      '<null>' as value
    from
      rss_item
    where
      feed_link = $1 and categories is null
    union 
    select
      '<All>' label,
      '<all>' as value  
    )
    select 
      label,
      value
    from
      categories
    order by label;
  EOQ

  param "feed_link" {}
}

query "rss_item_author" {
  sql = <<-EOQ
    with authors as (
    select
      case
        when author_name is null then '<No author>'
        else regexp_replace(author_name,'<[^>]*>', '','g') 
      end as label,
      case
        when author_name is null then '<null>'
        else regexp_replace(author_name,'<[^>]*>', '','g') 
      end as value
    from
      rss_item
    where
      feed_link = $1  
    union
    select
      '<All>' label,
      '<all>' as value
    ) 
    select 
      label,
      value
    from
      authors
    order by label;
  EOQ

  param "feed_link" {}
}

query "rss_item_published_month" {
  sql = <<-EOQ
    with published_month as (
    select
      to_char(published::date,'yyyy-mm') as label,
      to_char(published::date,'yyyy-mm') as value
    from
      rss_item
    where
      feed_link = $1
    union
    select
      '<All>' label,
      '<all>' as value
    )  
   select 
      label,
      value
    from
      published_month
    order by label desc;
  EOQ

  param "feed_link" {}
}

query "rss_item_by_published" {
  sql = <<-EOQ
    select
      to_char(published::date,'yyyy-mm') as published_month,
      count(*)
    from
      rss_item
    where
      case 
        when ($2)::text not like '%<all>%'
        then feed_link = $1 and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($2, ',')::text[]))
         
        else
          feed_link = $1
      end    
    group by
      published_month
    order by
      published_month;
  EOQ

  param "feed_link" {}
  param "published_month" {}
}

query "rss_item_by_author" {
  sql = <<-EOQ
    select
      case
        when author_name is null then '<No author>'
        else regexp_replace(author_name,'<[^>]*>', '','g') 
        end as author_name,
      count(*)
    from
      rss_item
    where
      case 
        when ($2)::text not like '%<all>%' and ($2)::text not like '%<null>%'
        then feed_link = $1 and regexp_replace(author_name,'<[^>]*>', '','g') in (select unnest (string_to_array($2, ',')::text[]))
        
        when ($2)::text not like '%<all>%' and ($2)::text like '%<null>%'
        then feed_link = $1 and (regexp_replace(author_name,'<[^>]*>', '','g') in (select unnest (string_to_array($2, ',')::text[])) or author_name is null)
        
        else
          feed_link = $1
      end    
    group by
      author_name
    order by
      author_name;
  EOQ

  param "feed_link" {}
  param "author" {}
}

query "rss_item_by_category" {
  sql = <<-EOQ
    with categories as (
    select
      title,
      feed_link,
      '<No category>' as category
    from
      rss_item
    where
      categories is null
    union  
    select
      title,
      feed_link,
      category
    from
      rss_item,
      jsonb_array_elements_text(categories) as category
    )
    select
      category,
      count(*)
    from
      categories
    where
      case 
        when ($2)::text not like '%<all>%' and ($2)::text not like '%<null>%'
        then feed_link = $1 and category in (select unnest (string_to_array($2, ',')::text[]))
        
        when ($2)::text not like '%<all>%' and ($2)::text like '%<null>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[])) or category = '<No category>')
        
        else
          feed_link = $1
      end      
    group by
      category
    order by
      count desc;    
  EOQ

  param "feed_link" {}
  param "category" {}
}

query "rss_channel_table" {
  sql = <<-EOQ
    select
      title as "Title",
      link as "Link",
      feed_type as "Feed Type",
      language as "Language",
      updated as "Updated"
    from
      rss_channel
    where
      feed_link = $1;
  EOQ

  param "feed_link" {}
}
query "rss_item_table" {
  sql = <<-EOQ
    with items as(
    select
      title,
      link,
      case
        when author_name is null then ''
        else regexp_replace(author_name,'<[^>]*>', '','g') 
        end as author_name,
      categories,
      published,
      feed_link,
      '' as "category"
    from
      rss_item
    where
      categories is null
    union (
    select
      title,
      link,
      case
        when author_name is null then ''
        else regexp_replace(author_name,'<[^>]*>', '','g') 
        end as author_name,
      categories,
      published,
      feed_link,
      category
    from
      rss_item,
      jsonb_array_elements_text(categories) as category)
    )
    select
      distinct title as "Title",
      link as "Link",
      author_name as "Author Name",
      categories as "Categories",
      published as "Published"
    from
      items  
    where
      case 
        when (($2)::text not like '%<all>%' and ($2)::text not like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text not like '%<null>%') and ($4)::text not like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[]))
        and author_name in (select unnest (string_to_array($3, ',')::text[]))) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when (($2)::text not like '%<all>%' and ($2)::text not like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text not like '%<null>%') and ($4)::text like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[]))
        and author_name in (select unnest (string_to_array($3, ',')::text[])))

        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text not like '%<all>%'
        then feed_link = $1 and ((category in (select unnest (string_to_array($2, ',')::text[])) or category = '')
        and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = '')) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text like '%<all>%'
        then feed_link = $1 and ((category in (select unnest (string_to_array($2, ',')::text[])) or category = '')
        and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = ''))
        
        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text not like '%<null>%') and ($4)::text not like '%<all>%'
        then feed_link = $1 and ((category in (select unnest (string_to_array($2, ',')::text[])) or category = '')
        and author_name in (select unnest (string_to_array($3, ',')::text[]))) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))

        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text not like '%<null>%') and ($4)::text like '%<all>%'
        then feed_link = $1 and ((category in (select unnest (string_to_array($2, ',')::text[])) or category = '')
        and author_name in (select unnest (string_to_array($3, ',')::text[])))
        
        when (($2)::text not like '%<all>%' and ($2)::text not like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text not like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[]))
        and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = '')) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when (($2)::text not like '%<all>%' and ($2)::text not like '%<null>%') and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[]))
        and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = ''))
        
        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and ($3)::text like '%<all>%' and ($4)::text not like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[])) or category = '') and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when (($2)::text not like '%<all>%' and ($2)::text like '%<null>%') and ($3)::text like '%<all>%' and ($4)::text like '%<all>%'
        then feed_link = $1 and (category in (select unnest (string_to_array($2, ',')::text[])) or category = '')
        
        when ($2)::text like '%<all>%' and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text not like '%<all>%'
        then feed_link = $1 and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = '') and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when ($2)::text like '%<all>%' and (($3)::text not like '%<all>%' and ($3)::text like '%<null>%') and ($4)::text like '%<all>%'
        then feed_link = $1 and (author_name in (select unnest (string_to_array($3, ',')::text[])) or author_name = '')

        when ($2)::text not like '%<all>%' and ($3)::text like '%<all>%' and ($4)::text not like '%<all>%'
        then feed_link = $1 and category in (select unnest (string_to_array($2, ',')::text[])) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))
        
        when ($2)::text not like '%<all>%' and ($3)::text like '%<all>%' and ($4)::text like '%<all>%'
        then feed_link = $1 and category in (select unnest (string_to_array($2, ',')::text[]))
        
        when ($2)::text like '%<all>%' and ($3)::text not like '%<all>%' and ($4)::text not like '%<all>%'
        then feed_link = $1 and author_name in (select unnest (string_to_array($3, ',')::text[])) and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))

        when ($2)::text like '%<all>%' and ($3)::text not like '%<all>%' and ($4)::text like '%<all>%'
        then feed_link = $1 and author_name in (select unnest (string_to_array($3, ',')::text[]))
        
        when ($2)::text like '%<all>%' and ($3)::text like '%<all>%' and ($4)::text not like '%<all>%'
        then feed_link = $1 and to_char(published::date,'yyyy-mm') in (select unnest (string_to_array($4, ',')::text[]))

        else
          feed_link = $1
      end    
    order by
      published desc;
  EOQ

  param "feed_link" {}
  param "category" {}
  param "author" {}
  param "published_month" {}
}