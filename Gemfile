ruby '4.0.5'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.1.3'
gem 'pg'
gem 'puma'
gem 'aws-sdk-s3', require: false
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'

gem 'stripe'
gem 'record_tag_helper'

gem 'devise'
gem 'omniauth-facebook'
# gem 'omniauth-twitter'
# gem 'omniauth-amazon'
# gem 'omniauth-github'
# gem 'omniauth-instagram'
# gem 'omniauth-medium'
# gem 'omniauth-pinterest'
# gem 'omniauth-slack'
# gem 'omniauth--twitch'

gem 'cancancan'
gem 'redcarpet'
gem 'actionview-encoded_mail_to'
gem 'attr_default'
gem 'google-analytics-rails'
# gem 'google-webfonts-rails', :github => 'masarakki/google-webfonts-rails', :branch => 'for-rails5'

# gem 'prawn'
# gem 'markdown_prawn', :github => 'vanboom/markdown_prawn'

# gem 'mailersend-ruby'

gem 'resque'
gem 'resque_mailer'
gem 'net-http'

gem 'rollbar'
gem 'oj'

gem 'kaminari'
# gem 'mtg_sdk'
gem 'json'
gem 'awesome_print'
gem 'flag_shih_tzu'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails'
  gem 'fabrication'
  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen'
  # gem 'spring'
  # gem 'spring-watcher-listen'
end

gem 'tzinfo-data', platforms: %i[windows jruby]
