# React Development Guide

## Hooks

### useState

```javascript
import { useState } from 'react'

function Counter() {
  const [count, setCount] = useState(0)
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  )
}
```

### useEffect

```javascript
import { useEffect, useState } from 'react'

function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  
  useEffect(() => {
    const fetchUser = async () => {
      const response = await fetch(`/api/users/${userId}`)
      const data = await response.json()
      setUser(data)
    }
    
    fetchUser()
  }, [userId]) // Re-run when userId changes
  
  return user ? <div>{user.name}</div> : <div>Loading...</div>
}
```

### useRef

```javascript
import { useRef, useEffect } from 'react'

function AutoFocusInput() {
  const inputRef = useRef(null)
  
  useEffect(() => {
    inputRef.current.focus()
  }, [])
  
  return <input ref={inputRef} />
}
```

### useContext

```javascript
import { createContext, useContext, useState } from 'react'

const ThemeContext = createContext()

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light')
  
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  return useContext(ThemeContext)
}

// Usage
function ThemedButton() {
  const { theme, setTheme } = useTheme()
  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      Toggle Theme
    </button>
  )
}
```

## Custom Hooks

```javascript
// hooks/useFetch.js
import { useState, useEffect } from 'react'

export function useFetch(url) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url)
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        const json = await response.json()
        setData(json)
      } catch (err) {
        setError(err)
      } finally {
        setLoading(false)
      }
    }
    
    fetchData()
  }, [url])
  
  return { data, loading, error }
}

// Usage
function UserList() {
  const { data: users, loading, error } = useFetch('/api/users')
  
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

## React Router

```javascript
import { BrowserRouter, Routes, Route, Link, useParams, useNavigate } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/users">Users</Link>
      </nav>
      
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/users" element={<UserList />} />
        <Route path="/users/:id" element={<UserDetail />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  )
}

function UserDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  
  return (
    <div>
      <h1>User {id}</h1>
      <button onClick={() => navigate('/users')}>Back to Users</button>
    </div>
  )
}
```

## Redux Toolkit

```javascript
// store/todosSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { todoApi } from '../api/todo'

export const fetchTodos = createAsyncThunk(
  'todos/fetchTodos',
  async () => {
    const response = await todoApi.getAll()
    return response.data
  }
)

const todosSlice = createSlice({
  name: 'todos',
  initialState: {
    items: [],
    loading: false,
    error: null
  },
  reducers: {
    addTodo: (state, action) => {
      state.items.push(action.payload)
    },
    toggleTodo: (state, action) => {
      const todo = state.items.find(t => t.id === action.payload)
      if (todo) {
        todo.completed = !todo.completed
      }
    },
    removeTodo: (state, action) => {
      state.items = state.items.filter(t => t.id !== action.payload)
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchTodos.pending, (state) => {
        state.loading = true
      })
      .addCase(fetchTodos.fulfilled, (state, action) => {
        state.items = action.payload
        state.loading = false
      })
      .addCase(fetchTodos.rejected, (state, action) => {
        state.error = action.error.message
        state.loading = false
      })
  }
})

export const { addTodo, toggleTodo, removeTodo } = todosSlice.actions
export default todosSlice.reducer
```

## Ant Design Form

```jsx
import { Form, Input, Button, message } from 'antd'
import { userApi } from '../api/user'

const UserForm = ({ onSuccess }) => {
  const [form] = Form.useForm()
  
  const handleSubmit = async (values) => {
    try {
      await userApi.create(values)
      message.success('创建成功')
      form.resetFields()
      onSuccess?.()
    } catch (error) {
      message.error(error.message)
    }
  }
  
  return (
    <Form form={form} onFinish={handleSubmit} layout="vertical">
      <Form.Item
        name="username"
        label="用户名"
        rules={[{ required: true, message: '请输入用户名' }]}
      >
        <Input />
      </Form.Item>
      
      <Form.Item
        name="email"
        label="邮箱"
        rules={[
          { required: true, message: '请输入邮箱' },
          { type: 'email', message: '请输入正确的邮箱格式' }
        ]}
      >
        <Input />
      </Form.Item>
      
      <Form.Item>
        <Button type="primary" htmlType="submit">
          提交
        </Button>
      </Form.Item>
    </Form>
  )
}

export default UserForm
```

## Performance Optimization

### React.memo

```javascript
const UserCard = React.memo(({ user, onEdit }) => {
  console.log('UserCard rendered')
  return (
    <div>
      <h3>{user.name}</h3>
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  )
})
```

### useMemo & useCallback

```javascript
function TodoList({ todos, onToggle }) {
  const completedCount = useMemo(
    () => todos.filter(t => t.completed).length,
    [todos]
  )
  
  const handleToggle = useCallback((id) => {
    onToggle(id)
  }, [onToggle])
  
  return (
    <div>
      <p>Completed: {completedCount}</p>
      {todos.map(todo => (
        <TodoItem key={todo.id} todo={todo} onToggle={handleToggle} />
      ))}
    </div>
  )
}
```
