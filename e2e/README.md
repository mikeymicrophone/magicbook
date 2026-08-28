# Browser smokes (Playwright)

Guest Chromium smokes for MAG-29 surfaces: public 200s, chapter URLs, and Stripe Checkout.js price. They do not boot Rails, sign in, or complete a charge.

## Local

Start the app (and Vite) as usual, then:

```sh
bin/rails s -p 3001
# another terminal:
bin/vite dev

npm run test:e2e
npm run test:e2e:headed   # watch the browser
```

Default `BASE_URL` is `http://magicbook.test`. Override with `BASE_URL=http://localhost:3001` if you are not using that hostname. Use a database whose featured book (`DEFAULT_BOOK_IDS`) is *Ways We Enjoy Magic Cards* at `$5.00` with a published edition so Free Chapter does not 500. The suite asserts Checkout.js `data-amount` matches the subtitle price and rejects the MAG-29 sentinels `$2` (`200`) and `$10` (`1000`).

## Staging

After a deploy:

```sh
BASE_URL=https://your-staging-host npm run test:e2e:staging
```

Railway’s current staging hostname is `https://magicbook-staging-staging.up.railway.app` unless you have attached a custom domain. Staging must use Stripe **test** keys. The overlay spec opens Checkout.js and closes it; it never submits a card.

On the current staging deploy these MAG-29 detectors are expected to fail until the data and copy are fixed: Free Chapter 500s because `DEFAULT_BOOK_IDS` points at Editor Sandbox (no published edition), and `/purchases/new` still hardcodes Checkout.js `data-amount` `1000`.

## Failures

```sh
npx playwright show-report
```

Traces, screenshots, and video are kept on failure (`test-results/`, `playwright-report/`). Chromium only for now; one worker so a shared staging DB is not hammered in parallel.
