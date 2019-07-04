require 'meli'
require 'highline/import'
require 'pry-debugger'

def subcategories_to_scrap(meli, subcategory)
  subcategory_id = subcategory["id"]
  subcategory_count = subcategory["total_items_in_this_category"]
  if subcategory_count <= 10_000
    puts "#{subcategory_id} has #{subcategory_count} items"
    [subcategory_id]
  else
    response = JSON.parse meli.get("/categories/#{subcategory_id}").body
    puts "No children for category #{subcategory_id} with #{subcategory_count} items" if response["children_categories"].empty?
    response["children_categories"].map{ |subcategory| subcategories_to_scrap(meli, subcategory) }.flatten
  end
end

def categories_to_scrap(meli, category)
  response = JSON.parse meli.get("/categories/#{category}").body
  if response["total_items_in_this_category"] <= 10_000
    [category]
  else
    response["children_categories"].map{ |subcategory| subcategories_to_scrap(meli, subcategory) }.flatten
  end
end

meli_country_code = ENV['MELI_COUNTRY_CODE'] || ask('MeLi Country Code (or set MELI_COUNTRY_CODE):')
meli_app_id = ENV['MELI_APP_ID'] || ask('MeLi App ID (or set MELI_APP_ID):')
meli_app_secret = ENV['MELI_APP_SECRET'] || ask('MeLi App Secret (or set MELI_APP_SECRET):')
callback_url = ENV['MELI_APP_CALLBACK_URL'] || ask('MeLi App Callback URL (or set MELI_APP_CALLBACK_URL):')
root_category = ENV['MELI_ROOT_CATEGORY'] || ask('MeLi Root Category (or set MELI_ROOT_CATEGORY):')
meli = Meli.new(meli_app_id, meli_app_secret)
puts meli.auth_url(callback_url)
code = ask('code:')
meli.authorize(code, callback_url)

categories = categories_to_scrap(meli, root_category)
puts "Found #{categories.count} categories"

CATEGORIES_TO_SKIP = [ "MLAXXXXX" ]

categories.each { |category|
  if CATEGORIES_TO_SKIP.include? category
    puts "Skipping category #{category}"
    next
  end
  total_results = nil
  offset = 0

  while !total_results || offset < total_results do
    response = JSON.parse meli.get("/sites/#{meli_country_code}/search?category=#{category}&access_token=#{meli.access_token}&offset=#{offset}").body
    unless total_results
      total_results = response["paging"]["total"]
      puts "Getting #{total_results} items from category #{category}"
    end

    items = response["results"]
    items.each { |item|
      offset += 1
      puts "Got item #{item['id']}"
    }
    puts "Offset: #{offset}"
  end
}
