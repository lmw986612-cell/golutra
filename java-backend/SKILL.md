---
name: java-backend
description: Java后端开发技能，支持Spring Boot、Spring Cloud、MyBatis、JPA等主流框架。用于：(1)创建和配置Spring Boot项目，(2)编写RESTful API接口，(3)数据库设计和ORM映射，(4)微服务架构设计，(5)安全认证授权，(6)性能优化和调试。当用户需要Java后端开发、API设计、数据库操作、微服务相关工作时使用此技能。
---

# Java Backend Development Skill

## Quick Start

### Project Setup

Use Spring Initializr to bootstrap projects:
```
https://start.spring.io/
```

Minimal dependencies:
- spring-boot-starter-web
- spring-boot-starter-data-jpa
- mysql-connector-java (or postgresql)
- lombok

### Project Structure

```
src/main/java/com/example/demo/
├── controller/      # REST controllers
├── service/         # Business logic
├── repository/      # Data access (JPA repositories)
├── entity/          # JPA entities
├── dto/             # Data transfer objects
├── config/          # Configuration classes
├── exception/       # Custom exceptions
└── util/            # Utility classes
```

## Core Patterns

### Entity Definition

```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    private String username;
    
    @Column(nullable = false)
    private String password;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
}
```

### Repository Layer

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    boolean existsByUsername(String username);
    
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
}
```

### Service Layer

```java
@Service
@RequiredArgsConstructor
@Transactional
public class UserService {
    private final UserRepository userRepository;
    
    public User createUser(CreateUserDTO dto) {
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new BusinessException("Username already exists");
        }
        User user = new User();
        BeanUtils.copyProperties(dto, user);
        return userRepository.save(user);
    }
    
    public User getUser(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
```

### Controller Layer

```RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<User> create(@Valid @RequestBody CreateUserDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(userService.createUser(dto));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUser(id));
    }
}
```

## Exception Handling

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getMessage()));
    }
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException e) {
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(e.getMessage()));
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(message));
    }
}
```

## Configuration

### application.yml

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true

mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.example.demo.entity
```

## Common Dependencies

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.3</version>
    </dependency>
</dependencies>
```

## Reference Files

- [API Design Guide](references/api-design.md) - RESTful API设计规范
- [Database Guide](references/database.md) - 数据库设计和优化
- [Security Guide](references/security.md) - 安全认证授权
- [Microservices Guide](references/microservices.md) - 微服务架构
- [Testing Guide](references/testing.md) - 单元测试和集成测试
- [Deployment Guide](references/deployment.md) - Docker/K8s部署

## Scripts

- `scripts/init-spring-boot.sh` - Linux/Mac项目初始化脚本
- `scripts/init-spring-boot.ps1` - Windows PowerShell项目初始化脚本
