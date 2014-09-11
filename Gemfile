source "https://rubygems.org"

ruby "2.1.0"

gem 'sinatra',  '1.4.5', require: 'sinatra/base'
gem 'redis',    '3.1.0'
gem 'httparty', '0.13.1'
gem 'ffaker'
gem 'actionview',    '~> 4.1.5', require: "action_view"

# only used in development locally
group :development do
  gem 'pry'
  gem 'shotgun'
  gem 'sinatra-contrib', require: 'sinatra/reloader'

end

group :production do
  # gems specific just in the production environments
end

group :test do
  gem 'rspec'
  gem 'capybara', '~> 2.4.1'
end
