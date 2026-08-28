import { test, expect } from '@playwright/test'
import { visit, assertHealthy } from './helpers'

const publicPaths = [
  '/',
  '/wwemc',
  '/lists',
  '/card_sets',
  '/card_functions',
  '/books',
]

test.describe('guest public pages', () => {
  for (const path of publicPaths) {
    test(`${path} returns 200 without a Rails 500 page`, async ({ page }) => {
      await visit(page, path)
    })
  }

  test('Free Chapter nav link loads without a 500', async ({ page }) => {
    await visit(page, '/')
    await page.getByRole('link', { name: 'Free Chapter' }).click()
    await page.waitForLoadState('domcontentloaded')
    expect(page.url()).toMatch(/\/books\/.+\/chapters\/free/)
    await assertHealthy(page)
    await expect(page.locator('header.chapter_title')).toBeVisible()
  })

  test('opens one published list from the index', async ({ page }) => {
    await visit(page, '/lists')
    const listLink = page.locator('#lists a[href*="/lists/"]')
    test.skip((await listLink.count()) === 0, 'no published lists on this BASE_URL yet')
    await listLink.first().click()
    await page.waitForLoadState('domcontentloaded')
    expect(page.url()).toMatch(/\/lists\/\d+/)
    await assertHealthy(page)
    await expect(page.locator('[id^="masthead_of_list_"], [id^="name_of_list_"]').first()).toBeVisible()
  })

  test('opens one set from the set browser', async ({ page }) => {
    await visit(page, '/card_sets')
    const setLink = page.locator('.card-set-card a').first()
    await expect(setLink, 'expected at least one set on /card_sets').toBeVisible()
    await setLink.click()
    await page.waitForLoadState('domcontentloaded')
    expect(page.url()).toMatch(/\/card_sets\/[^/]+/)
    await assertHealthy(page)
    await expect(page.locator('.card-set-page h1').first()).toBeVisible()
  })

  test('opens one function from the taxonomy', async ({ page }) => {
    await visit(page, '/card_functions')
    const functionLink = page.locator('.function-card h2 a').first()
    await expect(functionLink, 'expected at least one function on /card_functions').toBeVisible()
    await functionLink.click()
    await page.waitForLoadState('domcontentloaded')
    expect(page.url()).toMatch(/\/card_functions\/[^/]+/)
    await assertHealthy(page)
    await expect(page.locator('.function-detail-page h1').first()).toBeVisible()
  })
})
