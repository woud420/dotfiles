# Cursor Rules - Language-Agnostic Project Standards

## Overview

This document defines the standardized patterns, conventions, and architectural principles for all projects based on the audit-log-service example. These rules ensure consistency, maintainability, and scalability across different technology stacks. The project it was generated off of was in Go.

## 1. Modularity & Structure

### Directory Layout

```
project-root/
├── src/                          # Main source code
│   ├── api/                      # Business logic layer
│   ├── handler/                  # HTTP/transport layer handlers
│   ├── model/                    # Data models and entities
│   │   ├── dao/                  # Data Access Objects
│   │   ├── dto/                  # Data Transfer Objects
│   │   │   ├── request/          # Request DTOs
│   │   │   └── response/         # Response DTOs
│   │   ├── entities/             # Core domain entities
│   │   └── repository/           # Repository interfaces
│   ├── modules/                  # Dependency injection modules
│   ├── routes/                   # Route definitions
│   ├── service/                  # Business services
│   └── errors/                   # Error definitions
├── test/                         # Test files
│   ├── unit/                     # Unit tests (mirror src structure)
│   └── integration/              # Integration tests
├── cmd/                          # Application entry points
├── scripts/                      # Utility scripts
├── examples/                     # Example data and configurations
├── bin/                          # Build artifacts
├── docs/                         # Documentation
│   └── architecture/             # Architecture documentation
├── docker-compose.yml            # Service orchestration
├── Dockerfile                    # Container definition
├── Makefile                      # Build and development commands
├── README.md                     # Project overview
└── .gitignore                    # Version control exclusions
```

### Naming Conventions

#### Files and Directories
- **snake_case** for file names: `audit_handler.go`, `user_service.py`
- **kebab-case** for directories: `load-test-env/`, `test-data/`
- **PascalCase** for class/struct files: `AuditEvent.java`, `UserModel.cs`

#### Code Elements
- **PascalCase** for public interfaces, classes, and structs
- **camelCase** for methods, functions, and variables
- **UPPER_SNAKE_CASE** for constants and environment variables
- **snake_case** for database fields and API parameters

#### Layer-Specific Naming
- **DAO**: `{Entity}DAO` (e.g., `UserDAO`, `AuditDAO`)
- **Repository**: `{Entity}Repository` (e.g., `UserRepository`)
- **Service**: `{Entity}Service` (e.g., `UserService`)
- **Handler**: `{Entity}Handler` (e.g., `UserHandler`)
- **DTO**: `{Entity}{Request|Response}` (e.g., `UserRequest`, `UserResponse`)

## 2. Build & Dev Tooling

### Makefile Structure

Every project must include a comprehensive Makefile with these standard targets:

```makefile
# Core Development
build              # Build the application
run                # Run the application locally
test               # Run all tests
test-unit          # Run unit tests only
test-integration   # Run integration tests only
test-coverage      # Generate coverage report

# Docker Operations
docker-up          # Start all services
docker-down        # Stop all services
docker-build       # Build container image

# Data Management
ingest             # Load test data
clear-data         # Clear test data

# Code Quality
lint               # Run linting tools
format             # Format code
clean              # Clean build artifacts

# Help
help               # Show available commands
```

### Scripts Directory

Maintain a `scripts/` directory with utility scripts:

- **Data Management**: `ingest-data.sh`, `clear-data.sh`
- **Testing**: `run-tests.sh`, `load-test.py`
- **Infrastructure**: `setup-env.sh`, `deploy.sh`
- **Development**: `generate-test-data.py`, `validate-schema.py`

### Docker Configuration

#### docker-compose.yml Requirements
- **Service Health Checks**: Every service must include health checks
- **Environment Variables**: Use `.env` files for configuration
- **Network Isolation**: Define custom networks for service communication
- **Volume Management**: Persistent data storage with named volumes
- **Resource Limits**: Define memory and CPU constraints

#### Dockerfile Best Practices
- **Multi-stage builds** for production optimization
- **Non-root user** for security
- **Layer caching** optimization
- **Health check** instructions
- **Environment-specific** configurations

## 3. Documentation & Metadata

### Required Documentation Files

#### README.md Structure
```markdown
# Project Name

Brief description of the project and its purpose.

## Features
- Key feature 1
- Key feature 2

## Quick Start
### Prerequisites
### Installation
### Usage

## API Documentation
### Endpoints
### Examples

## Architecture
### Components
### Data Flow

## Development
### Project Structure
### Available Commands
### Testing

## Configuration
### Environment Variables
### Service Configuration

## Production Considerations
### Performance
### Security
### Monitoring
```

#### Architecture Documentation (`docs/architecture/`)

Required files:
- `system-overview.md` - High-level system architecture
- `data-flow.md` - Data flow diagrams
- `api-design.md` - API design principles
- `deployment.md` - Deployment architecture
- `security.md` - Security considerations

### Mermaid Diagrams

Include these diagram types in architecture documentation:

```mermaid
# System Architecture
graph TB
    Client[Client] --> API[API Layer]
    API --> Service[Service Layer]
    Service --> Repository[Repository Layer]
    Repository --> Database[(Database)]

# Data Flow
sequenceDiagram
    participant C as Client
    participant A as API
    participant S as Service
    participant R as Repository
    participant D as Database
    
    C->>A: Request
    A->>S: Process
    S->>R: Query
    R->>D: Execute
    D-->>R: Result
    R-->>S: Data
    S-->>A: Response
    A-->>C: Response
```

## 4. Testing Strategy

### Test Organization

#### Directory Structure
```
test/
├── unit/                    # Unit tests (mirror src structure)
│   ├── handler/
│   ├── service/
│   ├── repository/
│   └── dao/
├── integration/             # Integration tests
│   ├── api/                 # API integration tests
│   ├── database/            # Database integration tests
│   └── external/            # External service tests
└── fixtures/                # Test data and fixtures
```

#### Test Naming Conventions
- **Unit Tests**: `{Component}_{Method}_{Scenario}_test.{ext}`
- **Integration Tests**: `{Component}_integration_test.{ext}`
- **Test Functions**: `Test{Component}_{Method}_{Scenario}`

#### Test Categories

##### Unit Tests
- **Handler Tests**: HTTP request/response validation
- **Service Tests**: Business logic validation
- **Repository Tests**: Data access logic
- **Utility Tests**: Helper function validation

##### Integration Tests
- **API Tests**: Full HTTP endpoint testing
- **Database Tests**: Data persistence validation
- **External Service Tests**: Third-party integration validation

#### Test Data Management
- **Fixtures**: Reusable test data structures
- **Factories**: Test data generation utilities
- **Mocks**: External dependency simulation
- **Cleanup**: Automatic test data cleanup

## 5. Design Principles

### Architectural Layers

#### 1. Transport Layer (Handler)
- **Responsibility**: HTTP request/response handling
- **Dependencies**: Business logic layer only
- **Patterns**: Request validation, response formatting, error handling

#### 2. Business Logic Layer (Service/API)
- **Responsibility**: Core business logic and orchestration
- **Dependencies**: Repository layer only
- **Patterns**: Transaction management, business rule enforcement

#### 3. Data Access Layer (Repository/DAO)
- **Responsibility**: Data persistence and retrieval
- **Dependencies**: Data models only
- **Patterns**: Repository pattern, DAO pattern, query optimization

#### 4. Data Model Layer (Entities/DTOs)
- **Responsibility**: Data structure definitions
- **Dependencies**: None (base layer)
- **Patterns**: Value objects, DTOs, domain entities

### Design Patterns

#### Repository Pattern
```typescript
// Interface definition
interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<User>;
  delete(id: string): Promise<void>;
}

// Implementation
class UserRepositoryImpl implements UserRepository {
  // Implementation details
}
```

#### Service Layer Pattern
```typescript
// Business logic orchestration
class UserService {
  constructor(private userRepository: UserRepository) {}
  
  async createUser(userData: CreateUserRequest): Promise<User> {
    // Business logic validation
    // Repository interaction
    // Response formatting
  }
}
```

#### Handler Pattern
```typescript
// HTTP request handling
class UserHandler {
  constructor(private userService: UserService) {}
  
  async createUser(req: Request, res: Response): Promise<void> {
    // Request validation
    // Service call
    // Response formatting
  }
}
```

### Separation of Concerns

#### Single Responsibility Principle
- Each class/function has one reason to change
- Clear boundaries between layers
- Minimal coupling between components

#### Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions
- Abstractions don't depend on details

#### Interface Segregation
- Clients don't depend on interfaces they don't use
- Small, focused interfaces
- Composition over inheritance

## 6. API Design Principles

### RESTful Design
- **Resource-based URLs**: `/api/v1/users/{id}`
- **HTTP method semantics**: GET, POST, PUT, DELETE
- **Status code consistency**: 200, 201, 400, 404, 500
- **Versioning**: URL path versioning (`/api/v1/`)

### Request/Response Patterns

#### Request DTOs
```typescript
interface CreateUserRequest {
  email: string;
  name: string;
  role: UserRole;
}

interface UpdateUserRequest {
  name?: string;
  role?: UserRole;
}
```

#### Response DTOs
```typescript
interface UserResponse {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  createdAt: string;
  updatedAt: string;
}

interface PaginatedResponse<T> {
  data: T[];
  total: number;
  limit: number;
  offset: number;
}
```

### Error Handling
- **Consistent error format**: `{ error: string, code?: string }`
- **Appropriate status codes**: 400 for client errors, 500 for server errors
- **Detailed logging**: Server-side error details with correlation IDs
- **User-friendly messages**: Client-safe error descriptions

### Query Parameters
- **Pagination**: `limit`, `offset`
- **Filtering**: `status`, `type`, `date_range`
- **Sorting**: `sort_by`, `sort_order`
- **Search**: `q` for general search

## 7. Data Management

### Entity Design
- **Immutable IDs**: UUID or auto-incrementing IDs
- **Audit fields**: `created_at`, `updated_at`, `created_by`, `updated_by`
- **Soft deletes**: `deleted_at` field for data retention
- **Versioning**: `version` field for optimistic locking

### Data Access Patterns
- **Repository abstraction**: Hide data source details
- **Query optimization**: Indexed fields, efficient queries
- **Connection pooling**: Database connection management
- **Transaction management**: ACID compliance

### Caching Strategy
- **Application-level caching**: In-memory caches
- **Database caching**: Query result caching
- **CDN caching**: Static resource caching
- **Cache invalidation**: Event-driven cache updates

## 8. Security Considerations

### Input Validation
- **Request validation**: All inputs validated and sanitized
- **SQL injection prevention**: Parameterized queries
- **XSS prevention**: Output encoding
- **CSRF protection**: Token-based protection

### Authentication & Authorization
- **JWT tokens**: Stateless authentication
- **Role-based access**: Granular permissions
- **API keys**: Service-to-service authentication
- **Rate limiting**: Request throttling

### Data Protection
- **Encryption at rest**: Sensitive data encryption
- **Encryption in transit**: TLS/SSL for all communications
- **PII handling**: Personal data protection
- **Audit logging**: Security event tracking

## 9. Performance Guidelines

### Optimization Strategies
- **Database indexing**: Strategic index placement
- **Query optimization**: Efficient query patterns
- **Connection pooling**: Resource reuse
- **Async processing**: Non-blocking operations

### Monitoring & Observability
- **Health checks**: Service availability monitoring
- **Metrics collection**: Performance metrics
- **Logging**: Structured logging with correlation IDs
- **Tracing**: Distributed request tracing

### Scalability Patterns
- **Horizontal scaling**: Load balancer distribution
- **Vertical scaling**: Resource allocation
- **Caching layers**: Multi-level caching
- **Database sharding**: Data distribution

## 10. Development Workflow

### Code Quality Standards
- **Linting**: Automated code style enforcement
- **Formatting**: Consistent code formatting
- **Code review**: Peer review requirements
- **Documentation**: Inline and external documentation

### Version Control
- **Branch naming**: `feature/`, `bugfix/`, `hotfix/` prefixes
- **Commit messages**: Conventional commit format
- **Pull requests**: Required for all changes
- **Release tagging**: Semantic versioning

### CI/CD Pipeline
- **Automated testing**: Unit, integration, and e2e tests
- **Code quality checks**: Linting, security scanning
- **Build automation**: Automated artifact creation
- **Deployment automation**: Environment-specific deployments

## 11. Environment Management

### Configuration Management
- **Environment variables**: Runtime configuration
- **Configuration files**: Environment-specific configs
- **Secrets management**: Secure credential storage
- **Feature flags**: Runtime feature toggles

### Environment Types
- **Development**: Local development setup
- **Staging**: Pre-production testing
- **Production**: Live environment
- **Testing**: Automated testing environment

## 12. Compliance & Standards

### Code Standards
- **Language-specific**: Follow language best practices
- **Framework conventions**: Adhere to framework patterns
- **Industry standards**: OWASP, SOLID principles
- **Team conventions**: Project-specific guidelines

### Documentation Standards
- **API documentation**: OpenAPI/Swagger specifications
- **Code documentation**: Inline comments and docstrings
- **Architecture documentation**: System design documents
- **User documentation**: End-user guides

---

## Implementation Checklist

When starting a new project, ensure all these elements are in place:

- [ ] Directory structure follows the defined layout
- [ ] Makefile includes all standard targets
- [ ] Docker configuration with health checks
- [ ] Comprehensive README.md
- [ ] Architecture documentation in `docs/architecture/`
- [ ] Test structure mirrors source code organization
- [ ] Repository pattern implementation
- [ ] Service layer abstraction
- [ ] Handler layer for transport concerns
- [ ] DTOs for request/response handling
- [ ] Error handling strategy
- [ ] Logging and monitoring setup
- [ ] Security considerations implemented
- [ ] CI/CD pipeline configuration
- [ ] Environment configuration management

This framework ensures consistent, maintainable, and scalable applications across different technology stacks and team compositions. 
