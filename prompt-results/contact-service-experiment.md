# Cursor Rules - Language-Agnostic Project Standards

## Overview

This document defines the standardized structure, conventions, and best practices for all projects based on the patterns established in the contact-service-experiment repository. These rules are designed to be language-agnostic and focus on architectural principles rather than implementation details. This document was generated from a source project in python.

## 1. Project Structure & Modularity

### Core Directory Layout

```
project-root/
├── src/                    # Main source code
│   ├── api/               # API layer (REST endpoints, GraphQL, etc.)
│   ├── model/             # Domain models and business logic
│   ├── datastore/         # Data access layer (repositories, ORM models)
│   ├── handler/           # Request/response handlers
│   ├── utils/             # Shared utilities and helpers
│   ├── scripts/           # Utility scripts and data processing
│   └── main.py           # Application entry point
├── tests/                 # Test suite
│   ├── api/              # API integration tests
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   └── conftest.py       # Test configuration and fixtures
├── dev/                   # Development tools and configurations
├── docs/                  # Documentation
├── architecture/          # Architecture diagrams and specifications
├── schema/               # Database schemas and migrations
├── docker-compose.yml    # Container orchestration
├── Makefile              # Build and development tasks
├── requirements.txt      # Dependencies (language-specific)
├── README.md             # Project documentation
└── .gitignore           # Version control exclusions
```

### Naming Conventions

#### Files and Directories
- Use **snake_case** for all file and directory names
- Separate concerns with clear, descriptive names
- Group related functionality in subdirectories
- Use plural forms for collections (e.g., `models/`, `tests/`)

#### Code Elements
- **Models**: Use **PascalCase** for class names
- **Functions/Methods**: Use **snake_case** for function and method names
- **Constants**: Use **UPPER_SNAKE_CASE** for constants
- **Variables**: Use **snake_case** for variables and parameters

## 2. Architectural Layers & Separation of Concerns

### Layer Structure

#### 1. API Layer (`src/api/`)
- **Purpose**: Handle HTTP requests, input validation, and response formatting
- **Responsibilities**:
  - Route definitions and endpoint handlers
  - Request/response serialization
  - Input validation and sanitization
  - Error handling and status codes
- **Patterns**: Controller pattern, dependency injection

#### 2. Model Layer (`src/model/`)
- **Purpose**: Define domain entities and business logic
- **Responsibilities**:
  - Domain model definitions
  - Business rule validation
  - Data transformation logic
  - Domain-specific algorithms
- **Patterns**: Domain-driven design, value objects, entities

#### 3. Data Access Layer (`src/datastore/`)
- **Purpose**: Manage data persistence and retrieval
- **Responsibilities**:
  - Database schema definitions
  - Query operations and data mapping
  - Transaction management
  - Connection pooling
- **Patterns**: Repository pattern, data mapper, unit of work

#### 4. Handler Layer (`src/handler/`)
- **Purpose**: Coordinate between layers and manage application flow
- **Responsibilities**:
  - Business logic orchestration
  - Cross-cutting concerns (logging, caching)
  - Service coordination
  - Error handling and recovery
- **Patterns**: Service layer, facade pattern

### Abstraction Patterns

#### Repository Pattern
- Abstract data access behind interfaces
- Provide consistent API for different data sources
- Enable easy testing and mocking

#### Service Layer Pattern
- Encapsulate business logic in service classes
- Coordinate between multiple repositories
- Handle complex operations and transactions

#### Model-View-Controller (MVC)
- Separate data models from presentation logic
- Use controllers to handle user input
- Maintain clear boundaries between layers

## 3. Build & Development Tooling

### Makefile Standards

```makefile
# Standard Makefile targets for all projects
.PHONY: setup run tests clean db db-init db-reset lint format

# Environment setup
setup: venv install-deps
venv: # Create virtual environment
install-deps: # Install dependencies

# Development
run: # Start development server
dev: # Start development environment with hot reload

# Testing
tests: # Run all tests
test-unit: # Run unit tests only
test-integration: # Run integration tests only
test-coverage: # Run tests with coverage

# Database
db: # Start database
db-init: # Initialize database schema
db-reset: # Reset database (drop and recreate)
db-migrate: # Run database migrations

# Code Quality
lint: # Run linting tools
format: # Format code
type-check: # Run type checking

# Cleanup
clean: # Remove generated files and caches
```

### Container Configuration

#### Docker Compose Structure
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/dbname
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./src:/app/src
      
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: dbname
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db_data:
```

### Development Environment

#### Required Files
- `requirements.txt` or equivalent dependency file
- `.env.example` for environment variable templates
- `docker-compose.yml` for containerized development
- `Makefile` for common development tasks

#### Environment Variables
- Use `.env` files for local development
- Never commit sensitive data to version control
- Provide `.env.example` with dummy values
- Use environment-specific configuration files

## 4. Testing Strategy

### Test Organization

#### Directory Structure
```
tests/
├── unit/                  # Unit tests for individual components
│   ├── model/            # Domain model tests
│   ├── datastore/        # Data access layer tests
│   └── utils/            # Utility function tests
├── integration/          # Integration tests
│   ├── api/              # API endpoint tests
│   └── database/         # Database integration tests
├── fixtures/             # Test data and fixtures
├── conftest.py           # Test configuration and shared fixtures
└── helpers/              # Test helper functions
```

#### Test Naming Conventions
- **Unit Tests**: `test_<function_name>_<scenario>.py`
- **Integration Tests**: `test_<feature>_integration.py`
- **API Tests**: `test_<endpoint>_<method>.py`

#### Test Patterns

##### Unit Test Structure
```python
def test_function_name_scenario():
    """Test description explaining the scenario being tested."""
    # Arrange - Set up test data and conditions
    input_data = {...}
    expected_result = {...}
    
    # Act - Execute the function being tested
    result = function_under_test(input_data)
    
    # Assert - Verify the expected outcome
    assert result == expected_result
```

##### Integration Test Structure
```python
def test_feature_integration():
    """Test complete feature workflow across multiple components."""
    # Setup test environment
    # Execute feature workflow
    # Verify end-to-end behavior
    # Clean up test data
```

### Testing Principles

#### Test Coverage Requirements
- **Unit Tests**: 80% minimum coverage for business logic
- **Integration Tests**: All critical user workflows
- **API Tests**: All public endpoints with various scenarios

#### Mocking Strategy
- Mock external dependencies (databases, APIs, file systems)
- Use dependency injection for testability
- Create test doubles for complex dependencies

#### Test Data Management
- Use factories for creating test data
- Implement database transactions for test isolation
- Provide cleanup mechanisms for test data

## 5. Documentation Standards

### Required Documentation Files

#### README.md Structure
```markdown
# Project Name

Brief description of the project and its purpose.

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Prerequisites

- Required software and versions
- System requirements
- Dependencies

## Installation

Step-by-step installation instructions.

## Usage

How to use the application with examples.

## API Documentation

Links to API documentation and examples.

## Development

Development setup and contribution guidelines.

## Testing

How to run tests and testing strategy.

## Deployment

Deployment instructions and configuration.

## License

License information.
```

#### Architecture Documentation (`architecture/`)
```
architecture/
├── overview.md           # High-level system overview
├── data-flow.md          # Data flow diagrams
├── component-diagram.md  # Component interaction diagrams
├── database-schema.md    # Database design and relationships
├── api-specification.md  # API design and contracts
└── deployment.md         # Deployment architecture
```

### Documentation Standards

#### Code Documentation
- Document all public APIs and interfaces
- Use clear, concise descriptions
- Include usage examples for complex functions
- Maintain documentation alongside code changes

#### Architecture Diagrams
- Use Mermaid diagrams for flow charts
- Include sequence diagrams for complex interactions
- Document data models and relationships
- Keep diagrams up-to-date with code changes

## 6. Design Principles

### Core Principles

#### Single Responsibility Principle
- Each class/module should have one reason to change
- Separate concerns into distinct layers
- Keep functions focused and cohesive

#### Dependency Inversion
- Depend on abstractions, not concrete implementations
- Use interfaces for external dependencies
- Enable easy testing and mocking

#### Don't Repeat Yourself (DRY)
- Extract common functionality into shared utilities
- Use inheritance and composition appropriately
- Create reusable components and patterns

#### Separation of Concerns
- Keep business logic separate from infrastructure
- Isolate data access from business rules
- Maintain clear boundaries between layers

### Design Patterns

#### Repository Pattern
```python
# Abstract interface
class ContactRepository:
    def find_by_email(self, email: str) -> Optional[Contact]:
        pass
    
    def save(self, contact: Contact) -> Contact:
        pass

# Concrete implementation
class DatabaseContactRepository(ContactRepository):
    def find_by_email(self, email: str) -> Optional[Contact]:
        # Database-specific implementation
        pass
```

#### Service Layer Pattern
```python
class ContactService:
    def __init__(self, contact_repo: ContactRepository):
        self.contact_repo = contact_repo
    
    def create_contact(self, contact_data: dict) -> Contact:
        # Business logic here
        contact = Contact(**contact_data)
        return self.contact_repo.save(contact)
```

#### Factory Pattern
```python
class ContactFactory:
    @staticmethod
    def create_from_opportunity(opportunity: Opportunity) -> Contact:
        # Factory logic for creating contacts
        pass
```

### Error Handling

#### Error Strategy
- Use consistent error types and messages
- Implement proper error logging
- Provide meaningful error responses to users
- Handle both expected and unexpected errors

#### Validation
- Validate input at API boundaries
- Use schema validation for data models
- Implement business rule validation
- Provide clear validation error messages

## 7. Code Quality Standards

### Code Style

#### General Guidelines
- Use consistent indentation and formatting
- Follow language-specific style guides
- Use meaningful variable and function names
- Keep functions small and focused
- Limit function complexity

#### Comments and Documentation
- Write self-documenting code
- Comment complex algorithms and business logic
- Document public APIs and interfaces
- Keep comments up-to-date with code changes

### Performance Considerations

#### Optimization Guidelines
- Profile code before optimizing
- Focus on algorithmic improvements first
- Use appropriate data structures
- Implement caching where beneficial
- Monitor performance in production

#### Database Optimization
- Use proper indexing strategies
- Optimize query patterns
- Implement connection pooling
- Use database transactions appropriately

### Security Standards

#### Security Principles
- Validate all input data
- Use parameterized queries
- Implement proper authentication and authorization
- Follow the principle of least privilege
- Keep dependencies updated

#### Data Protection
- Encrypt sensitive data at rest and in transit
- Implement proper session management
- Use secure communication protocols
- Follow data privacy regulations

## 8. Version Control & Collaboration

### Git Workflow

#### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature development branches
- `hotfix/*` - Critical bug fixes
- `release/*` - Release preparation branches

#### Commit Standards
- Use conventional commit messages
- Keep commits focused and atomic
- Write descriptive commit messages
- Reference issue numbers in commits

#### Pull Request Process
- Require code reviews for all changes
- Use automated testing and linting
- Update documentation with code changes
- Provide clear descriptions of changes

### Code Review Guidelines

#### Review Checklist
- [ ] Code follows project standards
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance impact considered
- [ ] Error handling is appropriate

#### Review Process
- Review for functionality and correctness
- Check code style and formatting
- Verify test coverage
- Ensure documentation is complete
- Consider security implications

## 9. Deployment & Operations

### Deployment Strategy

#### Environment Management
- Separate development, staging, and production environments
- Use environment-specific configuration
- Implement blue-green or canary deployments
- Monitor deployment health and rollback capabilities

#### Configuration Management
- Use environment variables for configuration
- Implement configuration validation
- Use secrets management for sensitive data
- Version control configuration templates

### Monitoring & Observability

#### Logging Standards
- Use structured logging
- Include correlation IDs for request tracing
- Log at appropriate levels (DEBUG, INFO, WARN, ERROR)
- Implement log aggregation and analysis

#### Metrics and Monitoring
- Monitor application health and performance
- Track business metrics and KPIs
- Implement alerting for critical issues
- Use distributed tracing for complex systems

### Disaster Recovery

#### Backup Strategy
- Regular automated backups
- Test backup restoration procedures
- Implement data retention policies
- Document recovery procedures

#### High Availability
- Design for fault tolerance
- Implement health checks and circuit breakers
- Use load balancing and auto-scaling
- Plan for regional failover if applicable

## 10. Maintenance & Evolution

### Technical Debt Management

#### Debt Tracking
- Identify and document technical debt
- Prioritize debt reduction based on impact
- Allocate time for debt reduction in sprints
- Monitor debt accumulation over time

#### Refactoring Guidelines
- Refactor incrementally and safely
- Maintain test coverage during refactoring
- Document architectural decisions
- Review and update patterns regularly

### Dependency Management

#### Dependency Strategy
- Keep dependencies up-to-date
- Use dependency vulnerability scanning
- Minimize dependency complexity
- Document dependency decisions

#### Version Pinning
- Pin dependency versions for stability
- Use semantic versioning
- Implement dependency update automation
- Test thoroughly before updating major versions

---

## Conclusion

These rules provide a foundation for consistent, maintainable, and scalable software development across all projects. They emphasize:

- **Modularity** and clear separation of concerns
- **Testability** and quality assurance
- **Documentation** and knowledge sharing
- **Security** and best practices
- **Maintainability** and long-term success

Adapt these rules to specific project needs while maintaining the core principles of clean architecture and good software engineering practices. 
