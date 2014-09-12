module ApplicationHelper
  NYT_KEY    = ENV["NYT_ALL_SEARCH_KEY"]
  ############# HELPERS ##############
# => Finds all the keys containing micro_posts and parses them back into a HASH.
  def all_micro_posts
    $redis.keys("*micro_posts*").map do |key|
      JSON.parse($redis.get(key))
    end
  end

  def set_micro_post(id, title, author, body, tags)
    hash  = {
      :blog_title => title,
      :author     => author,
      :blog_body  => body,
      :id         => id,
      :tags       => tags
    }
    json_hash = hash.to_json
    $redis.set("micro_posts:#{id}", json_hash)
  end

  def create_new_micro_post(title, author, body, tags)
    next_id = $redis.incr("micro_post:index")
    set_micro_post(next_id, title, author, body, tags)
  end

  def nyt_api(search)
    base_url      = "http://api.nytimes.com/svc/search/v2/articlesearch"
    @return       = HTTParty.get("#{base_url}.json?q=#{search}&fq=source:+new+york+times&api-key=#{NYT_KEY}")
    @simple_nyt   = @return["response"]["docs"]
  end

end
