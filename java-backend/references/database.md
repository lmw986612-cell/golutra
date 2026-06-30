# Database Design Guide

## Entity Relationships

### One-to-Many

```java
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}

@Entity
public class User {
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Order> orders;
}
```

### Many-to-Many

```java
@Entity
public class Student {
    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private Set<Course> courses;
}
```

## Indexing

```java
@Entity
@Table(indexes = {
    @Index(name = "idx_user_email", columnList = "email", unique = true),
    @Index(name = "idx_user_status", columnList = "status")
})
public class User {
    // ...
}
```

## Query Optimization

### Use JPQL for Complex Queries

```java
@Query("SELECT u FROM User u WHERE u.status = :status AND u.createdAt > :date")
List<User> findActiveUsersAfter(@Param("status") Status status, 
                                 @Param("date") LocalDateTime date);
```

### Use Native SQL When Needed

```Query(value = """
    SELECT u.*, COUNT(o.id) as order_count
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id
    HAVING COUNT(o.id) > 5
    """, nativeQuery = true)
List<Object[]> findFrequentBuyers();
```

## Transactions

```java
@Service
public class OrderService {
    
    @Transactional
    public Order createOrder(OrderDTO dto) {
        // Deduct stock
        productRepository.deductStock(dto.getProductId(), dto.getQuantity());
        
        // Create order
        Order order = new Order();
        // ... set fields
        
        return orderRepository.save(order);
    }
    
    @Transactional(readOnly = true)
    public Order getOrder(Long id) {
        return orderRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
    }
}
```

## Common Patterns

### Soft Delete

```java
@Entity
@EntityListeners(AuditingEntityListener.class)
public class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Deleted
    private Boolean deleted = false;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
}
```

### Auditing

```java
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditableEntity {
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedBy
    private String updatedBy;
}
```
