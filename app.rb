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
    $redis = Redis.new
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
    @micro_posts = $redis.keys("*micro_posts*").map { |micro_post| JSON.parse($redis.get(micro_post)) }
    render(:erb, :index)
  end

# NEW METHOD
  get('/micro_post/new') do
    render(:erb, :post_new)
  end


# CREATE METHOD
  post('/micro_post') do
    hash = {
      :blog_title => params[:blog_title],
      :author => params[:author],
      :blog_body => params[:blog_body],
    }
    next_id = $redis.incr("micro_post:index")
    hash[:id] = next_id
    json_hash = hash.to_json
    $redis.set("micro_posts:#{next_id}", json_hash)
    redirect to('/')
  end

# SHOW METHOD
  get('/micro_post/:id') do
    id = params[:id]
    @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
    render(:erb, :show)
  end

# DELETE METHOD

  delete('/micro_post/:id') do
    id = params[:id]
    $redis.del("micro_posts:#{id}")
    redirect to('/')
  end

end
