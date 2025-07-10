# Cursor Rules - Language-Agnostic Project Standards

## Overview

This document defines the architectural patterns, conventions, and best practices for all projects based on the analysis of the otter-log repository. These rules are designed to be language-agnostic and focus on structural organization, design principles, and development workflows. This document was generated off a project in rust.

## 1. Project Structure & Modularity

### Core Directory Layout

```
project-root/
├── src/                          # Main source code
│   ├── api/                      # Business logic layer (services)
│   ├── model/                    # Data models and persistence
│   ├── routes/                   # HTTP request handlers
│   ├── middleware/               # Cross-cutting concerns
│   ├── utils/                    # Shared utilities
│   ├── config/                   # Configuration management
│   └── main.rs                   # Application entry point
├── tests/                        # Integration tests
├── migrations/                   # Database schema migrations
├── docker/                       # Container configuration
├── k8s/                         # Kubernetes manifests
├── scripts/                      # Build and deployment scripts
├── docs/                         # Documentation
├── architecture/                 # System design documents
└── .github/                      # CI/CD workflows
```

### Naming Conventions

- **Directories**: Use snake_case for directory names
- **Files**: Use snake_case for file names
- **Modules**: Use snake_case for module names
- **Classes/Types**: Use PascalCase for type definitions
- **Functions/Methods**: Use snake_case for function names
- **Constants**: Use SCREAMING_SNAKE_CASE for constants
- **Variables**: Use snake_case for variables

### Module Organization

Each domain should follow this structure:
```
domain/
├── mod.rs                        # Module exports
├── model.rs                      # Data structures
├── dao.rs                        # Data access objects
├── service.rs                    # Business logic
├── error.rs                      # Error definitions
├── response.rs                   # API response types
└── mock_dao.rs                   # Test doubles
```

## 2. Architectural Layers

### Layered Architecture Pattern

1. **Presentation Layer** (`routes/`)
   - HTTP request/response handling
   - Input validation
   - Response formatting
   - Route definitions

2. **Business Logic Layer** (`api/`)
   - Service implementations
   - Business rules
   - Orchestration logic
   - Transaction management

3. **Data Access Layer** (`model/`)
   - Data Access Objects (DAOs)
   - Repository implementations
   - Database interactions
   - Caching logic

4. **Domain Layer** (`model/`)
   - Entity definitions
   - Value objects
   - Domain services
   - Business invariants

### Cross-Cutting Concerns (`middleware/`)

- Authentication & Authorization
- Logging & Monitoring
- Error handling
- Request/Response transformation
- Rate limiting
- CORS handling

## 3. Design Principles

### Separation of Concerns

- **Single Responsibility**: Each module/class has one reason to change
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Interface Segregation**: Clients depend only on interfaces they use
- **Open/Closed**: Open for extension, closed for modification

### Data Flow Patterns

1. **Request Flow**: `Route → Service → Repository → Database`
2. **Response Flow**: `Database → Repository → Service → Route`
3. **Error Flow**: `Error → Service → Route → Client`

### Abstraction Layers

```
┌─────────────────────────────────────┐
│           Presentation              │ ← Routes, Controllers
├─────────────────────────────────────┤
│           Business Logic            │ ← Services, Use Cases
├─────────────────────────────────────┤
│           Data Access              │ ← Repositories, DAOs
├─────────────────────────────────────┤
│           Infrastructure           │ ← Database, External APIs
└─────────────────────────────────────┘
```

## 4. Error Handling Strategy

### Error Hierarchy

```
BaseError
├── ValidationError
├── AuthenticationError
├── AuthorizationError
├── NotFoundError
├── DatabaseError
└── InternalError
```

### Error Response Format

```json
{
  "error": {
    "type": "error_type",
    "message": "Human-readable message",
    "code": "ERROR_CODE",
    "details": {},
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### Error Handling Rules

- Always return structured error responses
- Log errors with appropriate severity levels
- Don't expose internal implementation details
- Provide meaningful error messages
- Include error codes for programmatic handling

## 5. Testing Strategy

### Test Organization

```
tests/
├── unit/                          # Unit tests
├── integration/                   # Integration tests
├── e2e/                          # End-to-end tests
└── fixtures/                     # Test data
```

### Test Naming Conventions

- **Unit Tests**: `test_<function_name>_<scenario>`
- **Integration Tests**: `test_<feature>_<scenario>`
- **Test Files**: `<module_name>_test` or `test_<module_name>`

### Test Structure

### Mocking Strategy

- Create mock implementations for external dependencies
- Use trait-based abstractions for testability
- Implement mock DAOs for database testing
- Use dependency injection for service testing

## 6. Configuration Management

### Configuration Structure

```rust
pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub port: u16,
    pub environment: String,
}

impl Config {
    pub fn from_env() -> Self {
        // Load from environment variables
    }
}
```

## 7. Database Design

### Database Patterns

- Use connection pooling
- Implement proper indexing
- Handle database errors gracefully
- Use transactions for multi-step operations

## 8. API Design

### RESTful Conventions

- Use HTTP methods appropriately (GET, POST, PUT, DELETE)
- Return appropriate HTTP status codes
- Use consistent URL patterns
- Implement proper pagination

### API Response Format

```json
{
  "data": {},
  "meta": {
    "pagination": {},
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### Authentication

- Use JWT tokens for stateless authentication
- Implement proper token validation
- Include token expiration
- Support refresh tokens
## 10. Build & Deployment

### Makefile Structure

```makefile
# Development
dev-setup: ## Setup development environment
build: ## Build the application
test: ## Run all tests
fmt: ## Format code
lint: ## Run linter

# Database
db-create: ## Create database
db-migrate: ## Run migrations
db-reset: ## Reset database

# Docker
docker-build: ## Build Docker image
docker-run: ## Run Docker container
docker-push: ## Push to registry
```

## 11. Documentation Standards

### README Structure

```markdown
# Project Name

Brief description of the project.

## Features

- Key feature 1
- Key feature 2

## Quick Start

Installation and setup instructions.

## API Documentation

Link to API docs.

## Development

Development setup and guidelines.

## Deployment

Deployment instructions.
```

### Architecture Documentation

```
architecture/
├── README.md                     # Architecture overview
├── diagrams/                     # System diagrams
│   ├── system-overview.md
│   ├── data-flow.md
│   └── deployment.md
├── decisions/                    # Architecture decision records
└── specs/                       # Technical specifications
```

### API Documentation

- Use OpenAPI/Swagger for API documentation
- Include request/response examples
- Document error codes
- Provide authentication details

## 12. Development Workflow

### Git Workflow

- Use feature branches
- Require pull request reviews
- Run automated tests on PR
- Use conventional commit messages

### Code Quality

- Run linters and formatters
- Enforce code style guidelines
- Use static analysis tools
- Maintain test coverage

### CI/CD Pipeline

```yaml
name: CI/CD Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: make test
      - name: Run linter
        run: make lint
```

## 13. Monitoring & Observability

### Logging Strategy

- Use structured logging
- Include correlation IDs
- Log at appropriate levels
- Include context information

### Metrics

- Application metrics
- Business metrics
- Infrastructure metrics
- Custom dashboards

### Health Checks

- Database connectivity
- External service health
- Application readiness
- Custom health indicators

## 14. Performance Considerations

### Caching Strategy

- Application-level caching
- Database query caching
- CDN for static assets
- Cache invalidation strategies

### Database Optimization

- Proper indexing
- Query optimization
- Connection pooling
- Read replicas

### Scalability Patterns

- Horizontal scaling
- Load balancing
- Microservices architecture
- Event-driven patterns

## 15. Maintenance & Operations

### Backup Strategy

- Database backups
- Configuration backups
- Disaster recovery plans
- Backup testing

### Monitoring

- Application monitoring
- Infrastructure monitoring
- Alert configuration
- Incident response

### Updates & Maintenance

- Dependency updates
- Security patches
- Feature deprecation
- Version management

---

## Implementation Guidelines

1. **Start with the structure**: Always begin by setting up the directory structure
2. **Define interfaces first**: Create trait/interface definitions before implementations
3. **Write tests early**: Implement tests alongside features
4. **Document as you go**: Keep documentation current with code changes
5. **Follow the patterns**: Stick to established patterns for consistency
6. **Review regularly**: Periodically review and update these rules

## Language-Specific Adaptations

While these rules are language-agnostic, adapt them to your specific language:

- **Rust**: Use traits instead of interfaces, implement proper error handling
- **Python**: Use abstract base classes, implement type hints
- **TypeScript**: Use interfaces and types, implement proper error handling
- **Go**: Use interfaces, implement proper error handling with custom types

Remember: The goal is maintainable, testable, and scalable code that follows consistent patterns across the entire project. 

