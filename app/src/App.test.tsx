import { render, screen } from '@testing-library/react'
import { expect, test } from 'vitest'
import App from './App'

test('shows Hello Lutz', () => {
  render(<App />)

  expect(screen.getByText('Hello Lutz')).toBeVisible()
})
