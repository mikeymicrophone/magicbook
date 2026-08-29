import { test, expect } from '@playwright/test'
import { isLocalMagicbook, signInAsListOwner } from './helpers'

test.describe('tag style colors', () => {
  test('rounds styled chips and paints them with the style color', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })

    const chip = page.locator('.tagging-chip.is-styled').first()
    await expect(chip).toBeVisible()

    const styles = await chip.evaluate((element) => {
      const computed = getComputedStyle(element)
      return {
        radius: computed.borderRadius,
        color: element.style.getPropertyValue('--tag-color').trim()
      }
    })

    expect(Number.parseFloat(styles.radius)).toBeGreaterThan(8)
    expect(styles.color).toMatch(/^#[0-9a-f]{6}$/)
  })

  test('lets a mage preview and reset tag style colors on their profile', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/profile', { waitUntil: 'domcontentloaded' })

    await expect(page.getByRole('heading', { name: 'Profile' })).toBeVisible()

    const row = page.locator('.profile-style-color').filter({ hasText: 'Format' })
    await expect(row).toBeVisible()
    await expect(row.locator('input[type="color"]')).toHaveValue(/#[0-9a-f]{6}/)
    await expect(row.getByRole('button', { name: 'Use site color' })).toBeVisible()
  })

  test('applies a profile color override to chips, then restores the site color', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/profile', { waitUntil: 'domcontentloaded' })

    const row = page.locator('.profile-style-color').filter({ hasText: 'Format' })
    await row.locator('input[type="color"]').fill('#8a4a32')
    await page.getByRole('button', { name: 'Save colors' }).click()
    await expect(page.getByText('Tag style colors saved.')).toBeVisible()

    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })
    const chip = page.locator('.tagging-chip.is-styled').filter({ hasText: 'Format' }).first()
    await expect(chip).toHaveAttribute('style', /--tag-color:\s*#8a4a32/)

    await page.goto('/profile', { waitUntil: 'domcontentloaded' })
    await row.getByRole('button', { name: 'Use site color' }).click()
    await page.getByRole('button', { name: 'Save colors' }).click()
    await expect(page.getByText('Tag style colors saved.')).toBeVisible()

    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })
    await expect(chip).toHaveAttribute('style', /--tag-color:\s*#3d6b5a/)
  })
})
