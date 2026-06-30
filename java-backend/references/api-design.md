# RESTful API Design Guide

## URL Naming

```
GET    /api/users          # 获取用户列表
POST   /api/users          # 创建用户
GET    /api/users/{id}     # 获取单个用户
PUT    /api/users/{id}     # 更新用户
DELETE /api/users/{id}     # 删除用户

GET    /api/users/{id}/orders  # 获取用户的订单
```

## HTTP Status Codes

| Code | Usage |
|------|-------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (delete) |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |

## Request/Response Format

### Create Request
```json
POST /api/users
{
    "username": "john",
    "email": "john@example.com",
    "password": "123456"
}
```

### Success Response
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "id": 1,
        "username": "john",
        "email": "john@example.com"
    }
}
```

### Error Response
```json
{
    "code": 400,
    "message": "Username already exists",
    "data": null
}
```

## Pagination

```
GET /api/users?page=0&size=10&sort=createdAt,desc
```

Response:
```json
{
    "content": [...],
    "totalElements": 100,
    "totalPages": 10,
    "currentPage": 0,
    "size": 10
}
```

## Filtering

```
GET /api/users?status=ACTIVE&role=ADMIN
GET /api/products?minPrice=100&maxPrice=500
GET /api/orders?startDate=2024-01-01&endDate=2024-12-31
```

## Versioning

```
/api/v1/users
/api/v2/users
```

## Best Practices

1. Use nouns, not verbs in URLs
2. Use plural nouns for collections
3. Keep URLs shallow (max 3 levels)
4. Use query parameters for filtering
5. Return appropriate status codes
6. Version your API
