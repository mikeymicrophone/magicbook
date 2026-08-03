# Ways We Mage

Ways We Mage is a Rails application for publishing *Ways We Enjoy Magic Cards*, sharing and curating Magic lists, and browsing a lightweight card catalog. A purchased book grants the buyer access to the online edition and a limited number of gift invitations.

The card catalog deliberately models the information needed by this application—not a full Scryfall clone. It supports printings, sets, formats, shared card concepts, Oracle text, and a many-parent function taxonomy for browsing cards by what they do.

## Stack

- Ruby 4.0.5 and Rails 8.1
- PostgreSQL
- Sprockets/Sass, CoffeeScript, Turbolinks, and jQuery
- Devise for authentication and CanCanCan for authorization
- Stripe’s legacy Checkout/Charges integration for book purchases
- Resend SMTP for transactional mail
- Active Storage with Railway S3-compatible object storage in production
- Solid Queue worker process for queued mail and publishing work

## Local setup

Install the pinned Ruby with [mise](https://mise.jdx.dev/):

```sh
mise install
bundle install
```

Create the local PostgreSQL databases and load the schema:

```sh
createdb magicbook_dev_24
createdb magicbook_test
bundle exec rails db:prepare
```

Start the web process:

```sh
bin/rails server -p 3001
```

Then open <http://localhost:3001>.

### Publishing-editor sandbox

Sign in as a scribe, then use the isolated **Editor Sandbox** rather than a
real book while changing editor code. It contains enough ordered content to
exercise adding, editing, removing, promoting, and delaying paragraphs and
citations:

```sh
bundle exec rails editor:reset_sandbox
```

Open the path printed by the task (normally
`/books/2-Editor-Sandbox/edit`). Re-running the task discards only that
sandbox book's table-of-contents entries and recreates the test fixture.

For a realistic local author account and a skydiving sample book, run:

```sh
bundle exec rails editor:seed_skydiving
```

Then sign in at `/scribes/sign_in` with `skydiving@example.com` and password
`skydiving`. The task resets only the skydiving demo book's table of contents;
it runs in development only.

The `Procfile` also defines the production web process and a Solid Queue worker.
To process locally queued mail or publishing work, run the worker in a second terminal:

```sh
bin/jobs
```

## Configuration

Development uses the local PostgreSQL database configured in `config/database.yml`. Production reads `DATABASE_URL`.

Local environment variables are loaded from the ignored `.env` file with `dotenv-rails`. Copy `.env.example` if you need a fresh local setup, then add only Stripe **test-mode** keys and a Resend key if you want to exercise payments or actual email locally. Railway remains the source of truth for production variables.

Set secrets through your environment or Railway variables; never commit them. The production application uses these variables:

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | Production PostgreSQL connection URL. |
| `RAILS_ENV` | Set to `production` in production. |
| `RAILS_SERVE_STATIC_FILES` | Enable when the Rails service serves compiled assets. |
| `SECRET_KEY_BASE` | Rails session and message verifier secret. |
| `DEFAULT_BOOK_IDS` | ID of the featured/default book. |
| `STRIPE_PUBLISHABLE_KEY` | Browser-facing Stripe key. |
| `STRIPE_SECRET_KEY` | Server-side Stripe API key. |
| `RESEND_API_KEY` | Resend SMTP password/API key. |
| `CUSTOMER_SUPPORT_EMAIL_ADDRESS` | Contact address shown in the application. |
| `FACEBOOK_APP_ID` | Facebook login/share integration. |
| `RAILWAY_S3_ACCESS_KEY_ID` | Railway object-storage access key. |
| `RAILWAY_S3_SECRET_ACCESS_KEY` | Railway object-storage secret key. |
| `RAILWAY_S3_REGION` | Railway object-storage region. |
| `RAILWAY_S3_BUCKET` | Bucket used by Active Storage. |
| `RAILWAY_S3_ENDPOINT` | Railway S3-compatible endpoint. |

## Books and purchases

Books store their price as `price_cents`; the existing catalog defaults to `$5.00`. The book editor exposes this as **Price (cents)**. Checkout submits the selected book ID, while the server calculates the Stripe amount from the persisted book record. Do not trust a price submitted by the browser.

The current Stripe path is Stripe’s legacy Checkout/Charges flow. It is functional, but new payment work should migrate it to Checkout Sessions.

## Background jobs

Solid Queue uses the application PostgreSQL database; it does not need Redis for jobs. Mailers use `deliver_later`, and the worker is started with `bin/jobs`. The default queue configuration is in `config/queue.yml`; it includes the recurring cleanup of finished job records from `config/recurring.yml`.

Production needs a separate Railway worker service running `bin/jobs`. Keep it deployed alongside the web service before relying on queued mail or future PDF generation.

## Card catalog

The primary catalog relationships are:

```text
CardConcept ──< Card (a printing) >── CardSet
     │                                 │
     └──< CardFunctionAssignment >── CardFunction

CardSet ──< FormatSet >── Format
```

- `Card` is a particular printing: its set, collector number, image, and legacy Multiverse ID belong here. Lists point to printings.
- `CardConcept` represents the shared game object across printings. It stores Scryfall’s Oracle ID, Oracle text, and keywords.
- `CardFunction` is a directed acyclic taxonomy. A function may sit under multiple broader functions—for example, **Fight** belongs under both creature combat and damage removal.
- `CardSet` has a Scryfall set type and a broader browse category. `Format` is related to sets through `FormatSet`.

### Refresh Scryfall data

The normal importer downloads Scryfall’s public **Default Cards** bulk JSONL file. It chooses one ordinary printing per card/set, avoids premium variants where possible, preserves list links through legacy Multiverse IDs, and updates Oracle text on the shared concept.

```sh
bundle exec rake cards:ingest:scryfall
```

No Scryfall API key is required. This is a full catalog refresh and can take several minutes.

### Seed the current Standard taxonomy

After the catalog import, seed the current Standard environment and its baseline function classifications:

```sh
bundle exec rails db:seed
```

The seed is idempotent. It creates/updates the Standard format, connects its sets, creates the function graph, and applies the seeded function assignments using Oracle text and keywords.

## Tests and checks

Run focused tests while working on a subsystem:

```sh
bundle exec rspec spec/services/card_catalog/scryfall_bulk_ingest_spec.rb
bundle exec rspec spec/services/card_catalog/standard_environment_seeder_spec.rb
```

Run the whole suite with:

```sh
bundle exec rspec
```

The test database needs PostgreSQL and the extensions recorded in `db/schema.rb`.

Compile assets before a production deploy when validating CSS or JavaScript changes:

```sh
bundle exec rails assets:precompile
```

## Production deployment

The production service runs on Railway with PostgreSQL and Railway object storage. Before deploying, ensure the production variables above exist, especially Stripe, Resend, Active Storage, `DATABASE_URL`, and `RAILS_SERVE_STATIC_FILES`.

Deploy from this directory with the Railway CLI:

```sh
railway up --detach
railway deployment list --json
```

Do not treat a queued build as a successful release. Confirm the newest deployment reaches `SUCCESS`, then run the production database migration and any explicitly intended data task. Catalog import and Standard seeding mutate production data, so run them deliberately and separately from a normal code deploy.

## Useful URLs

- `/books` — books and purchased access
- `/lists` — community lists
- `/card_sets` — set browser
- `/card_functions` — function taxonomy browser
- `/cards/:id` — a printing and the lists that include it
