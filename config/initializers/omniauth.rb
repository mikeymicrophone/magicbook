# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], :scope => 'email'
#   provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
#   on_failure { |env| AuthenticationsController.action(:failure).call(env) }
# end
