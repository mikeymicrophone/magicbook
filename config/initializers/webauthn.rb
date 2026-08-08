origin = ENV.fetch('WEBAUTHN_ORIGIN') do
  Rails.env.production? ? 'https://wayswemage.com' : 'http://localhost:3000'
end

WebAuthn.configure do |config|
  config.allowed_origins = [origin]
  config.rp_id = ENV.fetch('WEBAUTHN_RP_ID', URI.parse(origin).host)
  config.rp_name = 'Ways We Mage'
end
