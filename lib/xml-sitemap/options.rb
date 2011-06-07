module XmlSitemap
  PERIODS = [
    :none,
    :always,
    :hourly,
    :daily,
    :weekly,
    :monthly,
    :yearly,
    :never
  ].freeze
  
  MAP_SCHEMA_OPTIONS = {
    'xsi:schemaLocation' => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd",
    'xmlns:xsi'          => "http://www.w3.org/2001/XMLSchema-instance",
    'xmlns'              => "http://www.sitemaps.org/schemas/sitemap/0.9"
  }.freeze
  
  INDEX_SCHEMA_OPTIONS = {
    'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9"
  }.freeze
end