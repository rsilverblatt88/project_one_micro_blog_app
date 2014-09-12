require './application_controller'
class App < ApplicationController



############### CONTROLER ###############
# INDEX METHOD
  get('/') do
# => @micro_posts contains all the keys in redis that contain "micro_posts" and parses them into a hash
# => so we can pull out the key value pairs to display

    title = params["blog_title"]
    if title.nil?
      @micro_posts = all_micro_posts
    else
      @micro_posts = all_micro_posts.select do |micro_post|

        # TODO: this is case-sensitive (and ugly)! let's change it to regex
        micro_post["blog_title"].downcase.match(title.downcase)
      end
    end
    render(:erb, :"blog_posts/index")
  end

# NEW METHOD
  get('/micro_post/new') do
    render(:erb, :"blog_posts/new")
  end

# CREATE METHOD
  post('/micro_post') do
    next_id = $redis.incr("micro_post:index")
    set_micro_post(next_id, params[:blog_title], params[:author], params[:blog_body], [])
    redirect to('/')
  end

# SHOW METHOD
# => the :id is passed from the index.erb file
# => then plugged into @micro_post to retrieve the specific post
get('/micro_post/:id') do
  id          = params[:id]
  @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
  render(:erb, :"blog_posts/show")
end

# SEARCH BY TITLE METHOD
get('/title') do
  title             = params["blog_title"]
  micro_posts       = all_micro_posts
  micro_posts.select do |micro_post|
    # TODO: this is case-sensitive (and ugly)! let's change it to regex
    micro_post["blog_title"].downcase.match(title.downcase)
  end


end

# DELETE METHOD

  delete('/micro_post/:id') do
    id = params[:id]
    $redis.del("micro_posts:#{id}")
    redirect to('/')
  end

# UPDATE(edit) METHOD
  get('/micro_post/:id/edit') do
    id          = params[:id]
    @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
    render(:erb, :"blog_posts/edit")
  end

#UPDATE POST ROUTE
  post('/micro_post/:id') do
    set_micro_post(params["id"], params["blog_title"], params["author"], params["blog_body"], params["tags"])
    # updated_hash = {
    #   :blog_title => params["blog_title"],
    #   :author => params["author"],
    #   :blog_body => params["blog_body"],
    #   :id => params["id"]
    # }
    # id        = params[:id]
    # json_hash = updated_hash.to_json
    # $redis.set("micro_posts:#{id}", json_hash)
    redirect to('/')
  end

  #ADD TAGS

  post('/add_tag/:id') do
    id = params[:id]
    set_micro_post(params["id"], params["blog_title"], params["author"], params["blog_body"], params["tags"])
    redirect to("/micro_post/#{id}")
  end

  #ADD COMMENTS
  post('/micro_post/:id/comments')do
  id            = params[:id]
  @micro_post   = JSON.parse($redis.get("micro_posts:#{id}"))
  @micro_post["comments"] = Array.new
  comment = {
          "user_name" => params["username"],
          "comment" => params["comment"],
  }
  @micro_post["comments"].push(comment)
  $redis.set("micro_posts:#{id}", @micro_post.to_json)
  redirect to("/micro_post/#{id}")
  end


  #################################
  #        API
  #################################

  get('/news_api') do
    nyt_api(params[:search_word])
    render(:erb, :api)
  end






end
