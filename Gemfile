ruby '3.1.2'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '6.1.7.6'
gem 'pg', '1.5.4'
gem 'puma'
gem 'sass-rails', '6.0'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'

gem 'stripe'
gem 'carrierwave'
gem 'fog-aws'
gem 'record_tag_helper', '1.0.1'

gem 'devise'
gem 'devise-token_authenticatable'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
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

gem 'mailersend_rails', :github => 'mikeymicrophone/mailersend_rails'

gem 'resque'
gem 'resque_mailer', '2.4.3'
gem 'net-http'

gem 'rollbar'
gem 'oj'

gem 'kaminari'
# gem 'mtg_sdk'
gem 'json'
gem 'awesome_print'
gem 'flag_shih_tzu'

group :development, :test do
  gem 'byebug', platform: :mri
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

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
