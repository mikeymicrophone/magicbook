unless Rails.env.test?
  non_production = !Rails.env.production? || ENV["RAILWAY_ENVIRONMENT_NAME"] == "staging"
  postshiba = !non_production || ENV["POSTSHIBA_API_KEY"].present?

  ActionMailer::Base.delivery_method = postshiba ? :postshiba : :file
  ActionMailer::Base.postshiba_settings = {
    api_key: ENV["POSTSHIBA_API_KEY"], cluster_id: ENV["POSTSHIBA_CLUSTER_ID"].presence
  }
  ActionMailer::Base.file_settings = { location: Rails.root.join("tmp/mails").to_s }
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true

  host = if Rails.env.development?
    "magicbook.test"
  elsif non_production
    "staging.wayswemage.com"
  else
    "wayswemage.com"
  end
  ActionMailer::Base.default_url_options = { host: ENV["APP_HOST"].presence || host, protocol: "https" }

  if non_production && postshiba
    raise "Set MAILER_TEST_RECIPIENT before enabling PostShiba outside production" if ENV["MAILER_TEST_RECIPIENT"].blank?

    class NonProductionMailInterceptor
      def self.delivering_email(message)
        message.to = ENV.fetch "MAILER_TEST_RECIPIENT"
        message.cc = nil
        message.bcc = nil
      end
    end

    ActionMailer::Base.register_interceptor NonProductionMailInterceptor
  end
end
