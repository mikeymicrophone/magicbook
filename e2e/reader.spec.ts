import { test, expect } from '@playwright/test'
import { visit, assertHealthy } from './helpers'

test.describe('book reader', () => {
  test('free chapter and next/prev URLs include book id and edition_id', async ({ page }) => {
    await visit(page, '/')
    await page.getByRole('link', { name: 'Free Chapter' }).click()
    await page.waitForLoadState('domcontentloaded')
    await assertHealthy(page)

    expect(page.url()).toMatch(/\/books\/\d+[^/]*\/chapters\/free/)
    const title = page.locator('header.chapter_title')
    await expect(title).toBeVisible()
    await expect(title).not.toHaveText('')

    const next = page.locator('a.next_chapter').first()
    const previous = page.locator('a.previous_chapter').first()
    const nextCount = await next.count()
    const previousCount = await previous.count()
    expect(nextCount + previousCount, 'free chapter should link to an adjacent chapter').toBeGreaterThan(0)

    const target = nextCount ? next : previous
    const href = await target.getAttribute('href')
    expect(href, 'adjacent chapter href').toBeTruthy()
    expect(href).toMatch(/\/books\/\d+[^/]*\/chapters\/\d+\/next/)
    expect(href).toMatch(/[?&]edition_id=\d+/)

    await target.click()
    await page.waitForLoadState('domcontentloaded')
    await assertHealthy(page)
    expect(page.url()).toMatch(/\/chapters\/\d+\/next/)
    expect(page.url()).toMatch(/[?&]edition_id=\d+/)
    await expect(page.locator('header.chapter_title')).toBeVisible()
    await expect(page.locator('header.chapter_title')).not.toHaveText('')
  })
})
