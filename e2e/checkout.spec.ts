import { test, expect, type Page, type Frame } from '@playwright/test'
import {
  visit,
  stripeAmounts,
  expectCheckoutMatchesFeaturedBook,
  FORBIDDEN_PRICE_CENTS,
} from './helpers'

test.describe('Stripe Checkout.js price', () => {
  test('homepage subtitle and purchase buttons agree, and are not $2 or $10', async ({ page }) => {
    await visit(page, '/')
    await expectCheckoutMatchesFeaturedBook(page)
  })

  test('wwemc and bookshelf purchase buttons match the featured book', async ({ page }) => {
    await visit(page, '/wwemc')
    await expectCheckoutMatchesFeaturedBook(page)

    await visit(page, '/books')
    await expectCheckoutMatchesFeaturedBook(page)
  })

  test('/purchases/new is not the hardcoded $10 Checkout.js snippet', async ({ page }) => {
    await visit(page, '/purchases/new')
    const amounts = await stripeAmounts(page)
    expect(amounts.length, 'Checkout.js snippet on /purchases/new').toBeGreaterThan(0)
    for (const amount of amounts) {
      expect(FORBIDDEN_PRICE_CENTS, `/purchases/new Checkout.js amount ${amount}`).not.toContain(amount)
    }
    await expectCheckoutMatchesFeaturedBook(page)
  })

  test('purchase CTA opens the Checkout.js overlay at the featured price and can be closed', async ({ page }) => {
    await visit(page, '/')
    const amount = (await stripeAmounts(page))[0]
    expect(amount).toBeTruthy()
    const dollars = (Number(amount) / 100).toFixed(2)

    const button = page.locator('.stripe-button-el').first()
    await expect(button, 'Checkout.js did not inject a button').toBeVisible({ timeout: 20_000 })

    const popupPromise = page.waitForEvent('popup', { timeout: 8_000 }).catch(() => null)
    await button.click()
    const popup = await popupPromise

    if (popup) {
      if (Number(amount) > 0) {
        await expect(popup.locator('body')).toContainText(dollars, { timeout: 15_000 })
      } else {
        await expect(popup.getByRole('button', { name: /pay/i })).toBeVisible({ timeout: 15_000 })
      }
      await popup.close()
      return
    }

    const frame = await stripeCheckoutFrame(page)
    if (Number(amount) > 0) {
      await expect(frame.locator('body')).toContainText(dollars)
    } else {
      await expect(frame.getByRole('button', { name: /pay/i })).toBeVisible()
    }

    const close = frame.getByRole('button', { name: /close/i }).or(
      frame.locator('[aria-label="Close"]')
    ).first()
    if (await close.count()) {
      await close.click()
    } else {
      await page.keyboard.press('Escape')
    }
  })
})

async function stripeCheckoutFrame(page: Page) {
  let found: Frame | undefined
  await expect.poll(async () => {
    for (const frame of page.frames()) {
      if (!frame.url().includes('checkout.stripe.com')) continue
      const pay = await frame.getByRole('button', { name: /pay/i }).isVisible().catch(() => false)
      const email = await frame.getByRole('textbox', { name: /email/i }).isVisible().catch(() => false)
      if (pay || email) {
        found = frame
        return true
      }
    }
    return false
  }, { timeout: 15_000, message: 'Checkout.js overlay did not open' }).toBe(true)

  expect(found, 'Checkout.js overlay frame').toBeTruthy()
  return found!
}
