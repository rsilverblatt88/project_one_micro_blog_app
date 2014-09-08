require 'sinatra/base'
require 'pry'
require 'redis'
require 'json'
require 'httparty'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################
  #NYT_KEY       = "ccb4fa2bd149de8f7ec969bf1034a03c:13:69768931"
  CLIENT_ID     = "29c059fa13494b009f4f4a59658f9e18"
  CLIENT_SECRET = "61d19061e8d542898bed0008778a3f94"
  WEBSITE_URL   = "http://localhost:3000"
  REDIRECT_URI  = "http://localhost:3000/oath_callback"

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

  ########################
  # Routes (GETS)
  ########################

  # READ METHOD ############
  get('/') do
    @micro_posts = $redis.keys("*micro_posts*").map { |micro_post| JSON.parse($redis.get(micro_post)) }
    render(:erb, :index)
  end
  ##########################

  # NEW METHOD ####
  get('/micro_post/new') do
    render(:erb, :post_new)
  end
  ##########################


  # SHOW METHOD #######
  # => Claytons Method(WHAT WAS THIS DOING?)
  get('/micro_post/post_id') do
    $title = params["specific_post"]
    erb :specific_post, {locals: {title: $title}}
  end
  #####################

  # SHOW METHOD 2 #########

  get('/micro_post/:id') do
    id = params[:id]
    @micro_post = JSON.parse $redis.get("micro_posts:#{id}")
    render(:erb, :show)
  end
  ##########################


  ########################
  # Routes (POSTS)
  ########################

# CREATE METHOD ###########
# => POSTS to the server - NEW BLOG ENTRY
  post('/micro_post') do
    hash = {
      :blog_title => params[:blog_title],
      :author => params[:author],
      :blog_body => params[:blog_body],
    }
    next_id = $redis.incr("micro_post:index")
    hash[:id] = next_id
    hash = hash.to_json
    $redis.set("micro_posts:#{next_id}", hash)
    redirect to('/')
  end
############################

# => Robs Method - Access by index*DOES NOT WORK*
# => Why is the correct route a GET and not a POST
  # post('/micro_post/post_id') do
  #   $title = params["specific_post"]
  #   redirect to ("/micro_post/post_id")
  #   binding.pry
  # end



  ########################
  # API ROUTES
  ########################

  # get('/insta_api') do
  # base_url = "https://api.instagram.com/oauth/authorize/"
  # @url     = "#{base_url}?client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&response_type=code"
  #   render(:erb, :insta)
  # end

  # get('/oath_callback') do
  #   code = params[:code]
  #   response = HTTParty.post(
  #     "https://api.instagram.com/oauth/access_token",
  #     :body => {
  #       client_id: CLIENT_ID,
  #       client_secret: CLIENT_SECRET,
  #       grant_type: "authorization_code",
  #       redirect_uri: REDIRECT_URI,
  #       code: code,
  #     },
  #     :headers => {
  #       "Accept" => "application/json"
  #     })
  #   binding.pry
  # end

end
