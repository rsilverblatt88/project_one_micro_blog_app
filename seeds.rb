require 'json'
require 'redis'

$redis = Redis.new(url: ENV["REDISTOGO_URL"])

# Clear out any old data
$redis.flushdb

$redis.set("micro_post:index", 0)


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


create_new_micro_post("Hello World", "PJ", "This is the body of the post", [])
create_new_micro_post("Hello World 2", "Robert", "This is the body of the post", [])
create_new_micro_post("Hello World 3", "Robert", "Whhhaaaaattt?????", [])
