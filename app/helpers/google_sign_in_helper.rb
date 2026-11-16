module GoogleSignInHelper
  def google_sign_in_button
    return unless Mage.google_oauth_configured?

    button_to mage_google_oauth2_omniauth_authorize_path(return_to: devise_controller? ? nil : request.fullpath), method: :post,
      class: "google-sign-in", aria: { label: "Continue with Google to Ways We Mage" },
      form: { class: "google-sign-in-form", data: { turbo: false, turbo_frame: "_top" } } do
      safe_join [
        image_tag("/google-g.png", alt: "", width: 18, height: 18),
        tag.span("Continue with Google", class: "google-sign-in-label"),
        image_tag("/google-sign-in-site.png", alt: "", width: 20, height: 20, class: "google-sign-in-site")
      ]
    end
  end
end
