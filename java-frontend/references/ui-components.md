# UI Components Guide

## Element Plus (Vue)

### Table

```vue
<template>
  <el-table :data="tableData" style="width: 100%">
    <el-table-column prop="date" label="Date" width="180" />
    <el-table-column prop="name" label="Name" width="180" />
    <el-table-column prop="address" label="Address" />
    <el-table-column label="Operations">
      <template #default="scope">
        <el-button size="small" @click="handleEdit(scope.row)">Edit</el-button>
        <el-button size="small" type="danger" @click="handleDelete(scope.row)">Delete</el-button>
      </template>
    </el-table-column>
  </el-table>
</template>
```

### Dialog

```vue
<template>
  <el-dialog v-model="dialogVisible" title="Tips" width="50%">
    <el-form :model="form" :rules="rules" ref="formRef">
      <el-form-item label="Name" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="dialogVisible = false">Cancel</el-button>
        <el-button type="primary" @click="handleSubmit">Confirm</el-button>
      </span>
    </template>
  </el-dialog>
</template>
```

### Form

```vue
<template>
  <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
    <el-form-item label="Activity name" prop="name">
      <el-input v-model="form.name" />
    </el-form-item>
    <el-form-item label="Activity zone" prop="region">
      <el-select v-model="form.region" placeholder="please select your zone">
        <el-option label="Zone one" value="shanghai" />
        <el-option label="Zone two" value="beijing" />
      </el-select>
    </el-form-item>
    <el-form-item label="Activity time" required>
      <el-col :span="11">
        <el-form-item prop="date1">
          <el-date-picker v-model="form.date1" type="date" placeholder="Pick a date" style="width: 100%" />
        </el-form-item>
      </el-col>
      <el-col :span="2">-</el-col>
      <el-col :span="11">
        <el-form-item prop="date2">
          <el-time-picker v-model="form.date2" placeholder="Pick a time" style="width: 100%" />
        </el-form-item>
      </el-col>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="submitForm(formRef)">Create</el-button>
      <el-button @click="resetForm(formRef)">Reset</el-button>
    </el-form-item>
  </el-form>
</template>
```

### Message & Notification

```javascript
import { ElMessage, ElMessageBox, ElNotification } from 'element-plus'

// Simple message
ElMessage.success('Success')
ElMessage.error('Error')

// Confirm dialog
const result = await ElMessageBox.confirm(
  'Are you sure?',
  'Warning',
  { confirmButtonText: 'OK', cancelButtonText: 'Cancel', type: 'warning' }
)

// Notification
ElNotification({
  title: 'Success',
  message: 'Operation completed',
  type: 'success'
})
```

## Ant Design (React)

### Table

```jsx
import { Table, Space, Button } from 'antd'

const columns = [
  {
    title: 'Name',
    dataIndex: 'name',
    key: 'name',
    sorter: (a, b) => a.name.localeCompare(b.name)
  },
  {
    title: 'Age',
    dataIndex: 'age',
    key: 'age',
    filters: [
      { text: 'Adult', value: 'adult' },
      { text: 'Child', value: 'child' }
    ],
    onFilter: (value, record) => record.age >= 18
  },
  {
    title: 'Action',
    key: 'action',
    render: (_, record) => (
      <Space size="middle">
        <Button type="link" onClick={() => handleEdit(record)}>Edit</Button>
        <Button type="link" danger onClick={() => handleDelete(record)}>Delete</Button>
      </Space>
    )
  }
]

<Table columns={columns} dataSource={data} rowKey="id" />
```

### Form

```jsx
import { Form, Input, Select, Button, DatePicker, message } from 'antd'

const UserForm = () => {
  const [form] = Form.useForm()
  
  const onFinish = async (values) => {
    try {
      await api.createUser(values)
      message.success('User created successfully')
      form.resetFields()
    } catch (error) {
      message.error(error.message)
    }
  }
  
  return (
    <Form form={form} onFinish={onFinish} layout="vertical">
      <Form.Item
        name="name"
        label="Name"
        rules={[{ required: true, message: 'Please input name' }]}
      >
        <Input />
      </Form.Item>
      
      <Form.Item
        name="email"
        label="Email"
        rules={[
          { required: true, message: 'Please input email' },
          { type: 'email', message: 'Invalid email format' }
        ]}
      >
        <Input />
      </Form.Item>
      
      <Form.Item name="role" label="Role">
        <Select>
          <Select.Option value="admin">Admin</Select.Option>
          <Select.Option value="user">User</Select.Option>
        </Select>
      </Form.Item>
      
      <Form.Item>
        <Button type="primary" htmlType="submit">Submit</Button>
      </Form.Item>
    </Form>
  )
}
```

### Modal

```jsx
import { Modal, Form, Input, message } from 'antd'

const UserModal = ({ visible, onClose, onSuccess }) => {
  const [form] = Form.useForm()
  
  const handleOk = async () => {
    try {
      const values = await form.validateFields()
      await api.createUser(values)
      message.success('Created successfully')
      form.resetFields()
      onSuccess?.()
      onClose()
    } catch (error) {
      if (error.errorFields) {
        // Validation error
        return
      }
      message.error(error.message)
    }
  }
  
  return (
    <Modal
      title="Create User"
      open={visible}
      onOk={handleOk}
      onCancel={onClose}
    >
      <Form form={form} layout="vertical">
        <Form.Item name="name" label="Name" rules={[{ required: true }]}>
          <Input />
        </Form.Item>
      </Form>
    </Modal>
  )
}
```

### Message & Notification

```javascript
import { message, notification, Modal } from 'antd'

// Simple message
message.success('Success')
message.error('Error')
message.warning('Warning')

// Notification
notification.success({
  message: 'Success',
  description: 'Operation completed successfully'
})

// Confirm
const result = await Modal.confirm({
  title: 'Are you sure?',
  content: 'This action cannot be undone',
  okText: 'Yes',
  cancelText: 'No'
})
```

## Common Patterns

### Loading State

```vue
<!-- Vue -->
<template>
  <div v-loading="loading">
    <el-table :data="data">...</el-table>
  </div>
</template>
```

```jsx
// React
import { Spin } from 'antd'

<Spin spinning={loading}>
  <Table data={data} />
</Spin>
```

### Empty State

```vue
<!-- Vue -->
<el-empty description="No data" />
```

```jsx
// React
import { Empty } from 'antd'

<Empty description="No data" />
```
