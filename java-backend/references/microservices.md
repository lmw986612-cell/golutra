# Microservices Guide

## Project Structure

```
microservices/
├── gateway/              # API Gateway
├── user-service/         # User management
├── order-service/        # Order management
├── product-service/      # Product catalog
├── common/               # Shared libraries
└── docker-compose.yml
```

## Service Discovery (Eureka)

```java
// pom.xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>

// Application.java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}

// application.yml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```

## API Gateway

```java
@SpringBootApplication
@EnableDiscoveryClient
public class GatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}

// application.yml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=1
        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1
```

## Inter-Service Communication

### Using OpenFeign

```java
@FeignClient(name = "user-service", fallbackFactory = UserClientFallbackFactory.class)
public interface UserClient {
    
    @GetMapping("/users/{id}")
    UserDTO getUser(@PathVariable("id") Long id);
    
    @GetMapping("/users/{id}/validate")
    boolean validateUser(@PathVariable("id") Long id);
}

// Fallback
@Component
public class UserClientFallbackFactory implements FallbackFactory<UserClient> {
    
    @Override
    public UserClient create(Throwable cause) {
        return new UserClient() {
            @Override
            public UserDTO getUser(Long id) {
                return new UserDTO(); // Return default or cached
            }
            
            @Override
            public boolean validateUser(Long id) {
                return false;
            }
        };
    }
}
```

### Using RestTemplate

```java
@Configuration
public class AppConfig {
    
    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}

@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public UserDTO getUser(Long userId) {
        return restTemplate.getForObject(
            "http://user-service/users/{id}", 
            UserDTO.class, 
            userId
        );
    }
}
```

## Circuit Breaker (Resilience4j)

```java
@CircuitBreaker(name = "userService", fallbackMethod = "getUserFallback")
public UserDTO getUser(Long id) {
    return userClient.getUser(id);
}

public UserDTO getUserFallback(Long id, Throwable t) {
    // Return cached or default user
    return new UserDTO();
}

// application.yml
resilience4j:
  circuitbreaker:
    instances:
      userService:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 10s
        permittedNumberOfCallsInHalfOpenState: 3
```

## Distributed Tracing (Micrometer + Zipkin)

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-brave</artifactId>
</dependency>
<dependency>
    <groupId>io.zipkin.reporter2</groupId>
    <artifactId>zipkin-reporter-brave</artifactId>
</dependency>
```

## Event-Driven (Kafka)

```java
// Producer
@Service
public class OrderEventPublisher {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void publishOrderCreated(OrderEvent event) {
        kafkaTemplate.send("order-events", event);
    }
}

// Consumer
@KafkaListener(topics = "order-events", groupId = "notification-service")
public void handleOrderCreated(OrderEvent event) {
    // Send notification
    notificationService.sendOrderConfirmation(event);
}
```

## Docker Compose

```yaml
version: '3.8'
services:
  eureka-server:
    build: ./eureka-server
    ports:
      - "8761:8761"
  
  gateway:
    build: ./gateway
    ports:
      - "8080:8080"
    depends_on:
      - eureka-server
  
  user-service:
    build: ./user-service
    depends_on:
      - eureka-server
      - mysql
  
  order-service:
    build: ./order-service
    depends_on:
      - eureka-server
      - mysql
  
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: mydb
    ports:
      - "3306:3306"
```
