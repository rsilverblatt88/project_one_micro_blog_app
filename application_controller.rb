require './helpers/application_helper'
# require 'sinatra/base'
#PRY must be removed when pushing to Heroku
# require 'pry'
# require 'redis'
require 'json'
# require 'httparty'

class ApplicationController < Sinatra::Base

  helpers ApplicationHelper

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

end
