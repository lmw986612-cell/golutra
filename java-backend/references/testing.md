# Java Testing Guide

## Unit Testing

### Service Test

```java
@SpringBootTest
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldCreateUser() {
        // Arrange
        CreateUserDTO dto = new CreateUserDTO("john", "john@example.com", "password");
        when(userRepository.existsByUsername(dto.getUsername())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(i -> {
            User user = i.getArgument(0);
            user.setId(1L);
            return user;
        });
        
        // Act
        User result = userService.createUser(dto);
        
        // Assert
        assertNotNull(result);
        assertEquals("john", result.getUsername());
        verify(userRepository).save(any(User.class));
    }
    
    @Test
    void shouldThrowExceptionWhenUsernameExists() {
        // Arrange
        CreateUserDTO dto = new CreateUserDTO("existing", "test@example.com", "password");
        when(userRepository.existsByUsername(dto.getUsername())).thenReturn(true);
        
        // Act & Assert
        assertThrows(BusinessException.class, () -> userService.createUser(dto));
    }
}
```

### Controller Test

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldReturnUser() throws Exception {
        // Arrange
        User user = new User(1L, "john", "john@example.com");
        when(userService.getUser(1L)).thenReturn(user);
        
        // Act & Assert
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("john"));
    }
    
    @Test
    void shouldReturn404WhenUserNotFound() throws Exception {
        // Arrange
        when(userService.getUser(999L)).thenThrow(new ResourceNotFoundException("User not found"));
        
        // Act & Assert
        mockMvc.perform(get("/api/users/999"))
            .andExpect(status().isNotFound());
    }
}
```

### Repository Test

```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldFindUserByUsername() {
        // Arrange
        User user = new User(null, "john", "john@example.com", "password");
        userRepository.save(user);
        
        // Act
        Optional<User> found = userRepository.findByUsername("john");
        
        // Assert
        assertTrue(found.isPresent());
        assertEquals("john@example.com", found.get().getEmail());
    }
}
```

## Integration Test

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestDatabase
class UserIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreateAndRetrieveUser() {
        // Create
        CreateUserDTO dto = new CreateUserDTO("john", "john@example.com", "password");
        ResponseEntity<User> createResponse = restTemplate.postForEntity(
            "/api/users", dto, User.class);
        
        assertEquals(HttpStatus.CREATED, createResponse.getStatusCode());
        User created = createResponse.getBody();
        
        // Retrieve
        ResponseEntity<User> getResponse = restTemplate.getForEntity(
            "/api/users/" + created.getId(), User.class);
        
        assertEquals(HttpStatus.OK, getResponse.getStatusCode());
        assertEquals("john", getResponse.getBody().getUsername());
    }
}
```

## Test Configuration

```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
```

## Best Practices

1. Use @MockBean for external dependencies
2. Use @DataJpaTest for repository tests (in-memory DB)
3. Use @WebMvcTest for controller tests (slice testing)
4. Follow Arrange-Act-Assert pattern
5. Test both success and failure scenarios
6. Use descriptive test names
