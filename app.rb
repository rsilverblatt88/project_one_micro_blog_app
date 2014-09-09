require 'sinatra/base'
require 'pry'
require 'redis'
require 'json'
require 'httparty'

class App < Sinatra::Base

########### CONFIGS ############
  configure do
    enable :logging
    enable :method_override
    enable :sessions
    $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

############### CONTROLER ###############

# INDEX METHOD
  get('/') do
# => @micro_posts contains all the keys in redis that contain "micro_posts" and parses them into a hash
# => so we can pull out the key value pairs to display
    @micro_posts = $redis.keys("*micro_posts*").map { |micro_post| JSON.parse($redis.get(micro_post)) }
    render(:erb, :index)
  end

# NEW METHOD
  get('/micro_post/new') do
    render(:erb, :post_new)
  end


# CREATE METHOD
  post('/micro_post') do
    hash  = {
      :blog_title => params[:blog_title],
      :author => params[:author],
      :blog_body => params[:blog_body],
    }
    next_id   = $redis.incr("micro_post:index")
    hash[:id] = next_id
    json_hash = hash.to_json
    $redis.set("micro_posts:#{next_id}", json_hash)
    redirect to('/')
  end

# SHOW METHOD
# => the :id is passed from the index.erb file
# => then plugged into @micro_post to retrieve the specific post
  get('/micro_post/:id') do
    id = params[:id]
    @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
    render(:erb, :show)
  end

# SEARCH BY TITLE METHOD
get('/title') do
  title = params["blog_title"]

end

# DELETE METHOD

  delete('/micro_post/:id') do
    id = params[:id]
    $redis.del("micro_posts:#{id}")
    redirect to('/')
  end

# UPDATE(edit) METHOD
  get('/micro_post/:id/edit') do
    id = params[:id]
    @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
    render(:erb, :edit_form)
  end

#UPDATE POST ROUTE
  post('/micro_post/:id') do
    updated_hash = {
      :blog_title => params["blog_title"],
      :author => params["author"],
      :blog_body => params["blog_body"],
      :id => params["id"]
    }
    id        = params[:id]
    json_hash = updated_hash.to_json
    $redis.set("micro_posts:#{id}", json_hash)
    redirect to('/')
  end

  #ADD TAGS

  post('/add_tag/:id') do
    id   = params[:id]
    updated_hash = {
      :blog_title => params["blog_title"],
      :author => params["author"],
      :blog_body => params["blog_body"],
      :id => params["id"],
      :tags => params["tags"],
    }
    $redis.set("micro_posts:#{id}", updated_hash.to_json)
    redirect to("/")
  end


  #################################
  #        API
  #################################

  # get('/nyt_api') do
  #   base_url      = "http://api.nytimes.com/svc/search/v2/articlesearch"
  #   nyt_key       = "ccb4fa2bd149de8f7ec969bf1034a03c:13:69768931"
  #   @response     = HTTParty.get("#{base_url}.json?q=tech&fq=source:+new+york+times&api-key=#{nyt_key}").to_json
  #   @parsed_nyt   = JSON.parse(@response)
  #   @simple_nyt   = @parsed_nyt["response"]["docs"]
  #   binding.pry
  #   render(:erb, :nyt_api)
  # end

  #nyt_api.erb file :
  # <% @simple_nyt.each do |simple| %>
  # <h1> <%= simple["web_url"] %>
  # <% end %>


end
