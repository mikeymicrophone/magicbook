# Ways We Mage — Marketing Plan

*Drafted 2026-08-03. Covers the next 90 days (Aug–Oct 2026) with a 12-month frame.*

**Scope assumption:** this is a plan for the whole property — the book *Ways We Enjoy Magic
Cards*, the coaching program, the crowd-sourced lists, and the new card catalog — not for a
single launch. If you meant a launch plan for one of those, say which and I'll cut this down.

---

## 1. What we actually sell

| Product | Price | Where it lives | State |
|---|---|---|---|
| *Ways We Enjoy Magic Cards* (PDF + online edition, 4 gift invites) | `books.price_cents` default **$5.00** | `/`, `/wwemc` | Live |
| Magic Coaching (weekly 15-min call) | $20/wk, $5 first call | `/coaching` | Live, unscaled |
| Crowd-sourced lists | Free (UGC) | `/lists` | Live, thin |
| Card catalog: sets, cards, functions | Free | `/card_sets`, `/cards`, `/card_functions` | **New, unpromoted** |

**Pricing inconsistency to settle first:** the OG description in
[purchases_helper.rb:74](app/helpers/purchases_helper.rb:74) says "$10 books," the migration
default is 500 cents, and the homepage says "most are affordable." Pick one number and make
the copy, the OG tag, and the DB agree. My recommendation: **$10**, with the free daily
chapter doing the discovery work. At $5 you are not cheap enough to be an impulse-free
purchase and you halve revenue per unit of the same marketing effort.

## 2. Who the buyer is

Three real segments, in order of how cheaply you can reach them:

1. **The returner.** Played in high school or during Arena's growth years, drifted, sees a
   Marvel or Avatar or Hobbit set trending and wonders whether to come back. Searches things
   like "is standard fun right now," "what cards do I need to start commander." High intent,
   low commitment, terrified of spending wrong. **This is the core buyer.** The book's actual
   pitch — *twenty ways to enjoy Magic, nine free* — is precisely a de-risking document for
   this person.
2. **The gift-giver.** Partner/parent/friend of a player. Doesn't play. Wants to understand
   or wants to give something. The 4-invite mechanic is built for them and they are the
   reason the book should read as a book, not a strategy guide.
3. **The curious beginner.** Highest volume, lowest conversion, and best served by the free
   chapter and the card catalog rather than by paid acquisition.

Explicitly **not** the target: the competitive Standard/Modern grinder. They have Channel
Fireball, coverage, and Discord, and they will not pay for prose about why Magic is fun.
Chasing them with content is the most likely way to waste the next quarter.

## 3. The strategic bet

The differentiated asset is not the book. It's **`/card_functions` — a plain-language
taxonomy of what cards do** ("Fight is both creature combat and damage-based removal").
Scryfall owns syntax search; EDHREC owns statistical recommendation; 17Lands owns limited
data. Nobody owns *"I don't know the vocabulary yet, show me what cards are for."*

That's the same thesis as the book, in software form. So the plan is:

> **Card catalog earns search traffic → free chapter converts it to email → book converts
> email to $10 → invites multiply each buyer by up to 4 → coaching monetizes the 2% who
> want more.**

Every channel below feeds that one pipe. If a tactic doesn't feed it, it's cut.

## 4. Channels, ranked by return per hour

### A. Organic search off the card catalog — *the flagship, 50% of effort*

You just built thousands of indexable pages and they are currently invisible: there's no
sitemap, `public/robots.txt` is all comments, and only the landing pages emit OG tags. Fix
that before writing a single post (see §6).

Target query families, all of which the taxonomy already answers:

- `mtg [set] best removal` / `cheap removal in standard 2026`
- `what does [mechanic] mean magic` — bounce, edict, ward, looting vs. rummaging
- `[card name] rulings / what deck is it good in`
- `standard 2026 card list by function`

Each function page and set page should end with the same offer block: *"This vocabulary is
chapter 3 of Ways We Enjoy Magic Cards. Read today's free chapter."*

**Target:** 200 indexed pages by Sept 1, 1,000 by Nov 1; 3,000 organic sessions/month by
Nov 1. These are goals to steer by, not forecasts — you have no organic baseline yet.

### B. Reddit and Discord — *30% of effort*

Where returners actually ask these questions. r/magicTCG, r/EDH, r/mtgvorthos, r/spikes
(avoid), plus the big set-release Discords. Rules: participate as a person, answer the
question completely in the comment, link the function page only when it adds something.
Ten genuinely useful comments a week beats any campaign. One self-post per month, maximum,
and only when you have a real artifact (e.g., "I classified every Standard card by what it
does — here's the browser, free").

### C. The free-chapter engine — *15% of effort, highest leverage*

`free_book_chapters_path` already serves a rotating free chapter daily. It is currently a
dead end: no email capture, no next step. Adding an email field to that page is the single
highest-ROI change in this plan. A daily-chapter email list is a recurring owned channel
that costs nothing per send.

### D. Coaching — *5% of effort, no acquisition spend*

Do not market coaching to strangers. It converts off the book and the free-chapter list only.
The $5 first-call offer is well-designed; put it in the book's final chapter and in the
post-purchase email ([book_mailer/purchased.html.erb](app/views/book_mailer/purchased.html.erb)),
which currently doesn't mention it.

### E. Paid — *$0 for now*

Don't. At $5–10 AOV with no measured LTV, paid social will lose money on every unit. Revisit
only after you can report cost-per-email and email→purchase rate for 60 days. The Facebook
pixel in the layout is a 2018 artifact; Facebook organic reach for a page like this is
effectively zero, and the `facebook_share_button` on every purchase CTA is doing nothing.
Replace with a plain copyable link and Bluesky/Discord share.

## 5. The 90-day calendar

**August — instrument and index.** Settle the price. Ship sitemap, robots, per-page OG and
meta descriptions, and email capture on the free chapter. Seed the catalog fully (the
`StandardEnvironmentSeeder` covers 18 Standard sets; extend to Commander staples next).
Set the GA4 conversion events. Post nothing promotional yet.

**September — publish and participate.** Write 8 function-page companion essays (one per
top-level function: interaction, card advantage, evasion, mana acceleration, resilience,
graveyard value, creature combat, card selection). Begin the Reddit/Discord cadence. First
daily-chapter emails go out.

**October — the release hook.** The next Standard set lands in this window; every set release
is a spike of exactly your buyer asking exactly your questions. Ship a "what the new set does,
by function" page within 48 hours of spoiler season ending, and promote it in the two channels
above. Prerelease weekend is the highest-traffic moment of the quarter — have the page live
before it, not after.

## 6. What engineering has to ship for any of this to work

Ordered by marketing value, all small:

1. **Email capture on the free chapter page** — [chapters/next.html.erb](app/views/chapters/next.html.erb)
   and the `free` collection route. Nothing else in the funnel matters if traffic can't be held.
2. **`sitemap.xml` + a real `robots.txt`** — the catalog is unindexable as shipped.
3. **Per-page `<title>`, meta description, and OG tags for cards, sets, and functions.**
   Today `open_graph_tags` is only wired into the landing pages and the layout hardcodes one
   title ([layouts/application.html.erb:4](app/views/layouts/application.html.erb:4)).
4. **Post-purchase email should sell the invites harder.** The 4-invite mechanic expires after
   **3 days** (`Purchase#fresh?`, `Muggle#time_since_purchase`). That window is too tight to be
   a growth loop — most buyers won't open the email in time. Extend to 30 days; this is the
   cheapest virality change available.
5. **A canonical `/start` page** for the returner: "haven't played since X, start here."
6. **GA4 events** for: free-chapter view, email signup, purchase, invite sent, invite claimed.
   Right now you can measure sessions and nothing else.

*Done: `/rank_my_jank` and its nav link have been removed — the page advertised a January date
and a dead Facebook event, which read as an abandoned project to anyone who landed there.*

## 7. Measurement

Report five numbers monthly, nothing else:

- Organic sessions to catalog pages
- Email subscribers (net new)
- Purchases, and revenue per email subscriber
- Invites sent per purchase (the virality coefficient — target > 1.5)
- Coaching calls booked

## 8. Budget

Effectively $0 in cash for 90 days: domain/hosting you already pay, plus ~$20/mo for email
sending. The real budget is time — roughly 6–8 hours/week, weighted 50% to catalog SEO work,
30% to community, 20% to writing and the email list.

## 9. The honest risk

The plan's whole load-bearing assumption is that the function taxonomy earns search traffic.
If after 90 days of correct indexing the catalog is not growing organic sessions month over
month, the answer is not more content — it's that Scryfall and EDHREC have the space locked
and the book needs a different front door. Decide that at the 90-day mark, not before.

Dropping the in-person event concentrates that risk rather than reducing it: acquisition is
now entirely online, and the only remaining word-of-mouth mechanic is the 4-invite loop —
which is why extending its 3-day window (§6, item 4) matters more than it did before. If the
SEO bet fails, the fallback is no longer "run the event more often"; it's finding a second
online front door, most likely video or a genuinely useful free tool.
