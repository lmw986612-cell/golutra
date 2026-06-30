# Frontend Testing Guide

## Vue Testing

### Unit Test (Vitest)

```javascript
// components/__tests__/UserCard.test.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import UserCard from '../UserCard.vue'

describe('UserCard', () => {
  it('renders user name', () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: 1, name: 'John', email: 'john@example.com' }
      }
    })
    
    expect(wrapper.text()).toContain('John')
  })
  
  it('emits edit event on button click', async () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: 1, name: 'John', email: 'john@example.com' }
      }
    })
    
    await wrapper.find('button').trigger('click')
    
    expect(wrapper.emitted('edit')).toBeTruthy()
    expect(wrapper.emitted('edit')[0]).toEqual([1])
  })
})
```

### Component Test (Vue Test Utils)

```javascript
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import UserList from '../UserList.vue'
import { useUserStore } from '@/stores/user'

describe('UserList', () => {
  it('fetches and displays users', async () => {
    const wrapper = mount(UserList, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              user: { users: [], loading: false }
            },
            createSpy: vi.fn
          })
        ]
      }
    })
    
    const store = useUserStore()
    store.fetchUsers = vi.fn()
    
    expect(store.fetchUsers).toHaveBeenCalled()
  })
})
```

## React Testing

### Unit Test (Jest + React Testing Library)

```javascript
// components/__tests__/UserCard.test.js
import { render, screen, fireEvent } from '@testing-library/react'
import UserCard from '../UserCard'

describe('UserCard', () => {
  it('renders user name', () => {
    render(<UserCard user={{ id: 1, name: 'John', email: 'john@example.com' }} />)
    
    expect(screen.getByText('John')).toBeInTheDocument()
  })
  
  it('calls onEdit when button is clicked', () => {
    const handleEdit = jest.fn()
    render(
      <UserCard 
        user={{ id: 1, name: 'John', email: 'john@example.com' }} 
        onEdit={handleEdit} 
      />
    )
    
    fireEvent.click(screen.getByText('Edit'))
    
    expect(handleEdit).toHaveBeenCalledWith(1)
  })
})
```

### Integration Test

```javascript
import { render, screen, waitFor } from '@testing-library/react'
import { Provider } from 'react-redux'
import { configureStore } from '@reduxjs/toolkit'
import userReducer from '../store/userSlice'
import UserList from '../UserList'
import { rest } from 'msw'
import { setupServer } from 'msw/node'

const server = rest.get('/api/users', (req, res, ctx) => {
  return res(
    ctx.json({
      content: [
        { id: 1, name: 'John', email: 'john@example.com' }
      ],
      totalElements: 1
    })
  )
})

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

it('fetches and displays users', async () => {
  const store = configureStore({
    reducer: { user: userReducer }
  })
  
  render(
    <Provider store={store}>
      <UserList />
    </Provider>
  )
  
  await waitFor(() => {
    expect(screen.getByText('John')).toBeInTheDocument()
  })
})
```

## API Test

```javascript
// api/__tests__/user.test.js
import { describe, it, expect } from 'vitest'
import { userApi } from '../user'
import axios from 'axios'
import MockAdapter from 'axios-mock-adapter'

const mock = new MockAdapter(axios)

describe('userApi', () => {
  it('fetches users', async () => {
    mock.onGet('/api/users').reply(200, {
      content: [{ id: 1, name: 'John' }]
    })
    
    const { data } = await userApi.getUsers()
    
    expect(data.content).toHaveLength(1)
    expect(data.content[0].name).toBe('John')
  })
  
  it('handles error', async () => {
    mock.onGet('/api/users').reply(401)
    
    await expect(userApi.getUsers()).rejects.toThrow()
  })
})
```

## E2E Test (Cypress)

```javascript
describe('User Management', () => {
  beforeEach(() => {
    cy.login('admin', 'password')
    cy.visit('/users')
  })
  
  it('displays user list', () => {
    cy.get('table').should('be.visible')
    cy.get('tbody tr').should('have.length.greaterThan', 0)
  })
  
  it('creates a new user', () => {
    cy.contains('button', '新增用户').click()
    
    cy.get('input[name="username"]').type('newuser')
    cy.get('input[name="email"]').type('new@example.com')
    cy.get('input[name="password"]').type('password123')
    
    cy.contains('button', '提交').click()
    
    cy.get('.el-message--success').should('contain', '创建成功')
  })
  
  it('deletes a user', () => {
    cy.get('tbody tr').first().within(() => {
      cy.contains('button', '删除').click()
    })
    
    cy.contains('.el-message-box', '确定删除').find('button').contains('确定').click()
    
    cy.get('.el-message--success').should('contain', '删除成功')
  })
})
```

## Test Configuration

### Vitest Config

```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/__tests__/']
    }
  }
})
```

### Jest Config

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterSetup: ['@testing-library/jest-dom'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'json', 'html']
}
```

## Best Practices

1. Test user interactions, not implementation details
2. Use data-testid for stable selectors
3. Mock API calls in unit tests
4. Use MSW for API mocking in integration tests
5. Write E2E tests for critical user flows
