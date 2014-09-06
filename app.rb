require 'sinatra/base'
require 'pry'
require 'redis'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################
  NYT_KEY       = "ccb4fa2bd149de8f7ec969bf1034a03c:13:69768931"
  CLIENT_ID     = "29c059fa13494b009f4f4a59658f9e18"
  CLIENT_SECRET = "61d19061e8d542898bed0008778a3f94"
  WEBSITE_URL   = "http://localhost:9292"
  REDIRECT_URI  = "http://localhost:9292/oath_callback"

  configure do
    enable :logging
    enable :method_override
    enable :sessions
    $redis = Redis.new
    @@test = []
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

  ########################
  # Routes (GETS)
  ########################

  get('/') do
    render(:erb, :index)
  end

  get('/post_new') do
    render(:erb, :post_new)
  end

  get('/oath_callback') do
  end

  ########################
  # Routes (POSTS)
  ########################

  post('/post_new') do
    new_post = {
      :blog_title => params[:blog_title],
      :author => params[:author],
      :blog_body => params[:blog_body],
    }
    $redis.set(1,"#{new_post}")
    binding.pry
  end

end
