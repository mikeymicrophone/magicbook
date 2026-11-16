# Configure transactional email

Magicbook sends through the PostShiba Action Mailer adapter. Existing mailers and queued deliveries use the same provider.

## Configure production

Create a Send only key named `magicbook-production` in the MICharisma PostShiba team. Store it as `POSTSHIBA_API_KEY` in the environment's secret manager and supply it to every web and worker process that sends mail. Use a separate key for each app and environment. These keys are team-scoped and can send from any of the team's verified domains.

Set `DELIVERY_EMAIL` to `Ways We Mage <hello@mail.wayswemage.com>` and `APP_HOST` to `wayswemage.com`. `POSTSHIBA_CLUSTER_ID` optionally pins the transactional cluster. Without it, PostShiba chooses a sending-ready cluster.

Use the existing `mail.wayswemage.com` sending domain in PostShiba. Publish the exact DKIM and return-path DNS records it supplies, and check the domain's SPF and DMARC alignment. Preserve existing mailbox MX records. PostShiba requires a verified sending domain, a sending-ready cluster, and production approval for external recipients.

After deployment, exercise an account or notification email to an approved recipient. Check its sender, HTTPS links, delivery event, and received authentication headers. A saved file or accepted API request does not verify inbox delivery.

## Exercise development and staging

Without `POSTSHIBA_API_KEY`, development and staging save messages under `tmp/mails` without contacting a provider. Local links use `https://magicbook.test`. Staging links use `https://staging.wayswemage.com`. `APP_HOST` overrides the link host.

Staging means either `RAILS_ENV=staging` or Railway's injected `RAILWAY_ENVIRONMENT_NAME=staging`, including services that run `RAILS_ENV=production`. Keep Railway's environment name as `staging` for these services. Test suites retain their existing `:test` mail delivery method.

To exercise PostShiba delivery outside production, create a separate Send only key named `magicbook-staging` or `magicbook-development`. Supply that key and set `MAILER_TEST_RECIPIENT` to your own address. The app replaces To with that address and clears Cc and Bcc before delivery. It refuses to boot with a non-production PostShiba key unless `MAILER_TEST_RECIPIENT` is present. Set the sender variable to an address on a verified PostShiba domain before enabling delivery. The sender domain still needs DNS verification.

PostShiba also supports `sandbox: true` on its cluster send API. It validates and composes without delivery, but still requires a verified domain and a sending-ready cluster. The Ruby Action Mailer adapter pinned here does not expose this option, so setting `sandbox` in `postshiba_settings` does not enable sandbox delivery.

See [PostShiba's Rails guide](https://www.postshiba.com/docs/send-with-rails), [API key setup](https://www.postshiba.com/docs/create-an-api-key), and [test sends](https://www.postshiba.com/docs/dashboard/emails/send-test-emails).

## Publish the pending DNS records

The [PostShiba sender domain](https://app.postshiba.com/account/sending_domains/NBVWGN) was added on 2026-11-16. DNS verification is pending. Names below are relative to `wayswemage.com`.

| Type | Name | Value |
| --- | --- | --- |
| CNAME | `ps1._domainkey.mail` | `1609.customers.postshiba.com` |
| CNAME | `rp.mail` | `rp.postshiba.com` |

Publish these as DNS-only records. If no existing DMARC policy covers the sender domain, PostShiba suggests a TXT record at `_dmarc.mail` with `v=DMARC1; p=none;`. Review the current policy before adding one. Recheck the dashboard's current records before publishing DNS.
