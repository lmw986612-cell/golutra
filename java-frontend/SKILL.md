---
name: java-frontend
description: Java项目前端开发技能，支持Vue、React等现代前端框架与Java后端集成。用于：(1)创建和配置前端项目，(2)与Java API对接，(3)状态管理和路由配置，(4)UI组件开发，(5)前端工程化和构建，(6)跨域处理和代理配置。当用户需要前端开发、Vue/React项目、前后端分离、API对接相关工作时使用此技能。
---

# Java Frontend Development Skill

## Quick Start

### Tech Stack

- **Framework**: Vue 3 / React 18
- **UI Library**: Element Plus / Ant Design
- **State Management**: Pinia / Redux Toolkit
- **HTTP Client**: Axios
- **Build Tool**: Vite

### Project Setup (Vue 3)

```bash
npm create vite@latest frontend -- --template vue
cd frontend
npm install
npm install axios element-plus pinia vue-router@4
```

### Project Setup (React)

```bash
npx create-react-app frontend
cd frontend
npm install axios antd @ant-design/icons react-router-dom @reduxjs/toolkit react-redux
```

## Project Structure

### Vue 3

```
src/
├── api/              # API请求
│   ├── index.js      # Axios实例
│   └── user.js       # 用户API
├── assets/           # 静态资源
├── components/       # 公共组件
├── router/           # 路由配置
├── stores/           # Pinia状态
├── views/            # 页面组件
├── utils/            # 工具函数
├── App.vue
└── main.js
```

### React

```
src/
├── api/              # API请求
│   ├── index.js      # Axios实例
│   └── user.js       # 用户API
├── assets/           # 静态资源
├── components/       # 公共组件
├── pages/            # 页面组件
├── store/            # Redux状态
├── utils/            # 工具函数
├── App.js
└── index.js
```

## Axios Configuration

```javascript
// api/index.js
import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000
})

// Request interceptor - add token
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// Response interceptor - handle errors
request.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          localStorage.removeItem('token')
          router.push('/login')
          ElMessage.error('登录已过期，请重新登录')
          break
        case 403:
          ElMessage.error('没有权限')
          break
        case 404:
          ElMessage.error('资源不存在')
          break
        default:
          ElMessage.error(error.response.data?.message || '请求失败')
      }
    } else {
      ElMessage.error('网络错误')
    }
    return Promise.reject(error)
  }
)

export default request
```

## API Module

```javascript
// api/user.js
import request from './index'

export const userApi = {
  login(data) {
    return request.post('/auth/login', data)
  },
  
  register(data) {
    return request.post('/auth/register', data)
  },
  
  getProfile() {
    return request.get('/users/profile')
  },
  
  updateProfile(data) {
    return request.put('/users/profile', data)
  },
  
  getUsers(params) {
    return request.get('/users', { params })
  },
  
  deleteUser(id) {
    return request.delete(`/users/${id}`)
  }
}
```

## Vue 3 Examples

### Router

```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/',
    component: () => import('@/layout/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue')
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/Users.vue'),
        meta: { requiresAuth: true, role: 'ADMIN' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.meta.requiresAuth && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

### Pinia Store

```javascript
// stores/user.js
import { defineStore } from 'pinia'
import { userApi } from '@/api/user'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.token,
    username: (state) => state.userInfo?.username || ''
  },
  
  actions: {
    async login(credentials) {
      const { data } = await userApi.login(credentials)
      this.token = data.token
      localStorage.setItem('token', data.token)
      await this.fetchUserInfo()
    },
    
    async fetchUserInfo() {
      const { data } = await userApi.getProfile()
      this.userInfo = data
    },
    
    logout() {
      this.token = ''
      this.userInfo = null
      localStorage.removeItem('token')
    }
  }
})
```

### Page Component

```vue
<!-- views/Users.vue -->
<template>
  <div class="users-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="showAddDialog">新增用户</el-button>
        </div>
      </template>
      
      <el-table :data="users" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="createdAt" label="创建时间" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="editUser(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteUser(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-pagination
        v-model:current-page="page"
        :page-size="10"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="fetchUsers"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { userApi } from '@/api/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const users = ref([])
const loading = ref(false)
const page = ref(1)
const total = ref(0)

const fetchUsers = async () => {
  loading.value = true
  try {
    const { data } = await userApi.getUsers({ page: page.value, size: 10 })
    users.value = data.content
    total.value = data.totalElements
  } finally {
    loading.value = false
  }
}

const deleteUser = async (id) => {
  await ElMessageBox.confirm('确定删除该用户？', '提示')
  await userApi.deleteUser(id)
  ElMessage.success('删除成功')
  fetchUsers()
}

onMounted(fetchUsers)
</script>
```

## React Examples

### Redux Store

```javascript
// store/userSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { userApi } from '../api/user'

export const login = createAsyncThunk(
  'user/login',
  async (credentials) => {
    const { data } = await userApi.login(credentials)
    localStorage.setItem('token', data.token)
    return data
  }
)

export const fetchProfile = createAsyncThunk(
  'user/fetchProfile',
  async () => {
    const { data } = await userApi.getProfile()
    return data
  }
)

const userSlice = createSlice({
  name: 'user',
  initialState: {
    token: localStorage.getItem('token') || '',
    userInfo: null,
    loading: false
  },
  reducers: {
    logout: (state) => {
      state.token = ''
      state.userInfo = null
      localStorage.removeItem('token')
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.fulfilled, (state, action) => {
        state.token = action.payload.token
        state.loading = false
      })
      .addCase(fetchProfile.fulfilled, (state, action) => {
        state.userInfo = action.payload
      })
  }
})

export const { logout } = userSlice.actions
export default userSlice.reducer
```

### Page Component

```jsx
// pages/Users.js
import React, { useEffect, useState } from 'react'
import { Table, Button, Space, Card, Popconfirm, message } from 'antd'
import { userApi } from '../api/user'

const Users = () => {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(false)
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10 })

  const fetchUsers = async (params = {}) => {
    setLoading(true)
    try {
      const { data } = await userApi.getUsers({
        page: params.current || pagination.current,
        size: params.pageSize || pagination.pageSize
      })
      setUsers(data.content)
      setPagination({ ...pagination, total: data.totalElements })
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id) => {
    await userApi.deleteUser(id)
    message.success('删除成功')
    fetchUsers()
  }

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '用户名', dataIndex: 'username', key: 'username' },
    { title: '邮箱', dataIndex: 'email', key: 'email' },
    { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt' },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button size="small" onClick={() => handleEdit(record)}>编辑</Button>
          <Popconfirm title="确定删除？" onConfirm={() => handleDelete(record.id)}>
            <Button size="small" danger>删除</Button>
          </Popconfirm>
        </Space>
      )
    }
  ]

  useEffect(() => {
    fetchUsers()
  }, [])

  return (
    <Card title="用户管理">
      <Table
        columns={columns}
        dataSource={users}
        loading={loading}
        pagination={pagination}
        onChange={fetchUsers}
        rowKey="id"
      />
    </Card>
  )
}

export default Users
```

## Proxy Configuration

### Vite

```javascript
// vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
```

### Create React App

```json
// package.json
{
  "proxy": "http://localhost:8080"
}
```

## Reference Files

- [Vue Guide](references/vue.md) - Vue 3详细开发指南
- [React Guide](references/react.md) - React详细开发指南
- [UI Components](references/ui-components.md) - 常用UI组件示例
- [Testing Guide](references/testing.md) - 前端测试指南(Vitest/Jest/Cypress)
