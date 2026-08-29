import { test, expect } from '@playwright/test'
import { isLocalMagicbook, signInAsListOwner } from './helpers'

test.describe('tag style picker', () => {
  test('shows the chosen style on the trigger and closes the menu', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })

    await page.locator('.list > .tagging').getByRole('button', { name: 'Tags' }).click()

    const picker = page.locator('#create_tag_list_219 .tagging-style-picker')
    const trigger = picker.locator('[data-create-tag-target="trigger"]')
    const menu = picker.locator('[data-create-tag-target="menu"]')

    await expect(trigger).toHaveText('#')
    await expect(trigger).toHaveAttribute('aria-label', 'Choose a style')
    await expect(menu).toBeHidden()

    await trigger.click()
    await expect(menu).toBeVisible()
    await expect(trigger).toHaveAttribute('aria-expanded', 'true')

    await menu.getByRole('option', { name: 'Format' }).click()

    await expect(menu).toBeHidden()
    await expect(trigger).toHaveAttribute('aria-expanded', 'false')
    await expect(trigger).toHaveText('Format')
    await expect(trigger).toHaveAttribute('aria-label', 'Style: Format')
    await expect(menu.locator('[data-style-name="Format"]')).toHaveAttribute('aria-selected', 'true')
  })

  test('keeps listed-item tagging closed until the tag icon is clicked', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })

    const item = page.locator('.listed_item').first()
    const toggle = item.getByRole('button', { name: 'Tags' })
    const panel = item.locator('.tagging-panel')

    await expect(toggle).toBeVisible()
    await expect(panel).toBeHidden()
    await expect(item.locator('.tagging-disclosure-panel .tagging-applied')).toHaveCount(0)

    await toggle.click()
    await expect(panel).toBeVisible()
    await expect(toggle).toHaveAttribute('aria-expanded', 'true')
  })

  test('shows applied item chips without opening the picker', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })

    const item = page.locator('.listed_item').filter({ hasText: 'Smaug' }).first()
    const chip = item.locator('.tagging-applied .tagging-chip').first()

    await expect(chip).toBeVisible()
    await expect(item.locator('.tagging-panel')).toBeHidden()
  })

  test('shows applied list chips without opening the picker', async ({ page }) => {
    test.skip(!isLocalMagicbook(), 'needs a local owner session, not staging')

    await signInAsListOwner(page)
    await page.goto('/lists/219-Hobbit-Characters', { waitUntil: 'domcontentloaded' })

    const chips = page.locator('.list > .tagging > .tagging-applied .tagging-chip')
    await expect(chips.first()).toBeVisible()
    await expect(page.locator('#create_tag_list_219')).toBeHidden()
  })
})
