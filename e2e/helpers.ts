import { expect, type Page, type Response } from '@playwright/test'

export const FORBIDDEN_PRICE_CENTS = ['200', '1000']

export async function visit(page: Page, path: string): Promise<Response> {
  const response = await page.goto(path, { waitUntil: 'domcontentloaded' })
  expect(response, `no response for ${path}`).toBeTruthy()
  expect(response!.status(), `${path} HTTP status`).toBe(200)
  await assertHealthy(page)
  return response!
}

export async function assertHealthy(page: Page): Promise<void> {
  const title = await page.title()
  expect(title, page.url()).not.toMatch(/something went wrong \(500\)/i)

  const body = await page.locator('body').innerText()
  expect(body, page.url()).not.toMatch(/We're sorry, but something went wrong/i)
}

export async function stripeAmounts(page: Page): Promise<string[]> {
  return page.locator('script.stripe-button').evaluateAll((scripts) =>
    scripts.map((script) => script.getAttribute('data-amount') || '')
  )
}

export async function subtitlePriceCents(page: Page): Promise<string> {
  const subtitle = await page.locator('#site_subtitle').innerText()
  const match = subtitle.match(/\$(\d+)\.(\d{2})/)
  expect(match, `subtitle should include a dollar price: ${subtitle}`).toBeTruthy()
  return String(Number(match![1]) * 100 + Number(match![2]))
}

export async function expectCheckoutMatchesFeaturedBook(page: Page): Promise<string> {
  const expected = await subtitlePriceCents(page)
  const amounts = await stripeAmounts(page)
  expect(amounts.length, `Stripe buttons on ${page.url()}`).toBeGreaterThan(0)
  for (const amount of amounts) {
    expect(FORBIDDEN_PRICE_CENTS, `${page.url()} Checkout.js amount ${amount}`).not.toContain(amount)
    expect(amount, `Checkout.js amount on ${page.url()} should match the featured book`).toBe(expected)
  }
  return expected
}
