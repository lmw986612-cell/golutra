# Vue 3 Development Guide

## Composition API

### Ref vs Reactive

```javascript
import { ref, reactive, computed } from 'vue'

// ref - for primitives
const count = ref(0)
console.log(count.value) // access with .value

// reactive - for objects
const state = reactive({
  name: 'John',
  items: []
})
console.log(state.name) // direct access

// computed
const doubleCount = computed(() => count.value * 2)
```

### Lifecycle Hooks

```javascript
import { onMounted, onUpdated, onUnmounted } from 'vue'

export default {
  setup() {
    onMounted(() => {
      console.log('Component mounted')
    })
    
    onUpdated(() => {
      console.log('Component updated')
    })
    
    onUnmounted(() => {
      console.log('Component unmounted')
    })
  }
}
```

## Component Communication

### Props

```vue
<!-- Parent -->
<ChildComponent :message="message" @update="handleUpdate" />

<!-- Child -->
<script setup>
const props = defineProps({
  message: String
})

const emit = defineEmits(['update'])

const handleClick = () => {
  emit('update', newValue)
}
</script>
```

### Provide/Inject

```vue
<!-- Parent -->
<script setup>
import { provide } from 'vue'
provide('theme', 'dark')
</script>

<!-- Child -->
<script setup>
import { inject } from 'vue'
const theme = inject('theme')
</script>
```

## Vue Router

### Dynamic Routes

```javascript
const routes = [
  {
    path: '/user/:id',
    name: 'UserDetail',
    component: () => import('@/views/UserDetail.vue'),
    props: true
  }
]

// In component
const route = useRoute()
const userId = route.params.id
```

### Navigation Guards

```javascript
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('token')
  
  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})
```

## Pinia Advanced

### Store with Modules

```javascript
// stores/counter.js
export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0,
    name: 'Counter'
  }),
  
  getters: {
    doubleCount: (state) => state.count * 2,
    doubleCountPlusOne() {
      return this.doubleCount + 1
    }
  },
  
  actions: {
    async increment() {
      await api.increment()
      this.count++
    },
    
    reset() {
      this.count = 0
    }
  }
})
```

### Using Store

```vue
<script setup>
import { useCounterStore } from '@/stores/counter'
import { storeToRefs } from 'pinia'

const counterStore = useCounterStore()
const { count, doubleCount } = storeToRefs(counterStore)
const { increment } = counterStore
</script>
```

## Transitions

```vue
<template>
  <Transition name="fade" mode="out-in">
    <div v-if="show" key="content">Content</div>
    <div v-else key="placeholder">Placeholder</div>
  </Transition>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
```

## Custom Hooks

```javascript
// composables/useApi.js
import { ref } from 'vue'

export function useApi(apiFn) {
  const data = ref(null)
  const loading = ref(false)
  const error = ref(null)
  
  const execute = async (...args) => {
    loading.value = true
    error.value = null
    try {
      data.value = await apiFn(...args)
    } catch (e) {
      error.value = e
    } finally {
      loading.value = false
    }
  }
  
  return { data, loading, error, execute }
}

// Usage
const { data: users, loading, execute: fetchUsers } = useApi(userApi.getUsers)
```

## Form Validation

```vue
<template>
  <el-form :model="form" :rules="rules" ref="formRef">
    <el-form-item label="用户名" prop="username">
      <el-input v-model="form.username" />
    </el-form-item>
    <el-form-item label="邮箱" prop="email">
      <el-input v-model="form.email" />
    </el-form-item>
  </el-form>
</template>

<script setup>
import { ref, reactive } from 'vue'

const formRef = ref(null)

const form = reactive({
  username: '',
  email: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
}

const handleSubmit = async () => {
  await formRef.value.validate()
  // Submit form
}
</script>
```
