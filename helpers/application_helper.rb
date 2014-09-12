module ApplicationHelper

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

end
