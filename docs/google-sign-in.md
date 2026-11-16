# Add Google sign-in to a page

Render `google_sign_in_button` in ERB:

```erb
<%= google_sign_in_button || link_to("Sign in", new_mage_session_path) %>
```

The helper renders only when `Mage.google_oauth_configured?` is true. It includes the Google G and the existing Ways We Mage square wordmark. The header and account sign-in page use the same helper.

Use `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` for the environment's Google web client. Register `/mages/auth/google_oauth2/callback` on its authorized redirect origin. Restart after credential changes. The helper sends a CSRF-protected POST and bypasses Turbo. Public-page buttons return to the current local path after successful authorization. Account-page buttons use the saved destination or the bookshelf. External destinations are rejected. Existing Mage identity and account-linking rules still apply.

Check the layout at `https://magicbook.test/mages/sign_in`. Use a registered public HTTPS development origin for a real Google callback. Focused checks are `spec/requests/google_sign_in_button_spec.rb` and `spec/models/mage_authentication_spec.rb`; they do not verify a live Google client.
