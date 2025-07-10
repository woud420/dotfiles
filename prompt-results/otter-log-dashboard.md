# Cursor Rules - Language-Agnostic Project Standards

## Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Conventions](#naming-conventions)
3. [Build & Development Tooling](#build--development-tooling)
4. [Documentation Standards](#documentation-standards)
5. [Testing Strategy](#testing-strategy)
6. [Design Principles](#design-principles)
7. [Code Organization](#code-organization)
8. [API Design Patterns](#api-design-patterns)
9. [State Management](#state-management)
10. [Error Handling](#error-handling)
11. [Security Considerations](#security-considerations)
12. [Performance Guidelines](#performance-guidelines)

## Project Structure

### Core Directory Layout
```
project-root/
├── src/                          # Source code
│   ├── api/                      # API layer and external integrations
│   ├── components/               # Reusable UI components
│   │   ├── ui/                  # Base UI components (buttons, inputs, etc.)
│   │   ├── layout/              # Layout components (headers, sidebars, etc.)
│   │   └── [domain]/            # Domain-specific components
│   ├── contexts/                # Global state management
│   ├── hooks/                   # Custom hooks and business logic
│   ├── pages/                   # Page-level components
│   │   ├── [domain]/            # Domain-specific pages
│   │   └── admin/               # Administrative pages
│   ├── types/                   # Type definitions and interfaces
│   ├── utils/                   # Utility functions and helpers
│   └── lib/                     # Third-party library configurations
├── tests/                       # Test files mirroring src structure
│   ├── api/                     # API tests
│   ├── components/              # Component tests
│   ├── hooks/                   # Hook tests
│   ├── pages/                   # Page tests
│   ├── contexts/                # Context tests
│   ├── utils/                   # Utility tests
│   └── mocks/                   # Mock data and handlers
├── docker/                      # Containerization files
├── public/                      # Static assets
├── docs/                        # Documentation
│   └── architecture/            # Architecture diagrams and specs
└── scripts/                     # Build and deployment scripts
```

### Required Root Files
- `README.md` - Project overview and setup instructions
- `Makefile` - Build automation and common tasks
- `.gitignore` - Version control exclusions
- `package.json` / `requirements.txt` / `Cargo.toml` - Dependencies
- `Dockerfile` - Container definition
- `docker-compose.yml` (optional) - Multi-service setup

## Naming Conventions

### File Naming
- **Components**: PascalCase (e.g., `UserProfile.tsx`, `BusinessUnitList.tsx`)
- **Hooks**: camelCase with `use` prefix (e.g., `useNetworkStatus.ts`, `useAuth.ts`)
- **Utilities**: camelCase (e.g., `apiClient.ts`, `userUtils.ts`)
- **Types/Interfaces**: PascalCase (e.g., `User.ts`, `ApiResponse.ts`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_ENDPOINTS.ts`, `STORAGE_KEYS.ts`)

### Directory Naming
- **Feature directories**: kebab-case (e.g., `business-units/`, `user-management/`)
- **Generic directories**: lowercase (e.g., `api/`, `utils/`, `hooks/`)
- **Domain directories**: lowercase (e.g., `admin/`, `dashboard/`)

### Code Naming
- **Variables**: camelCase
- **Functions**: camelCase
- **Classes**: PascalCase
- **Interfaces**: PascalCase with descriptive names
- **Enums**: PascalCase
- **Constants**: UPPER_SNAKE_CASE

## Build & Development Tooling

### Makefile Structure
```makefile
# Project variables
APP_NAME = [project-name]
DOCKER_IMAGE = $(APP_NAME):latest

# Development commands
.PHONY: install
install:
	[package-manager] install

.PHONY: dev
dev:
	[package-manager] run dev

.PHONY: build
build:
	[package-manager] run build

# Docker commands
.PHONY: docker-build
docker-build:
	docker build -t $(DOCKER_IMAGE) -f docker/Dockerfile .

.PHONY: docker-run
docker-run:
	docker run -p [port]:[port] $(DOCKER_IMAGE)

.PHONY: docker-stop
docker-stop:
	docker stop $$(docker ps -q --filter ancestor=$(DOCKER_IMAGE)) 2>/dev/null || true

.PHONY: docker-clean
docker-clean:
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

# Testing commands
.PHONY: test
test:
	[package-manager] run test

.PHONY: test:watch
test:watch:
	[package-manager] run test:watch

.PHONY: test:coverage
test:coverage:
	[package-manager] run test:coverage

# Help
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  install      - Install dependencies"
	@echo "  dev          - Start development server"
	@echo "  build        - Build for production"
	@echo "  test         - Run tests"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run Docker container"
	@echo "  help         - Show this help message"

.DEFAULT_GOAL := help
```

### Docker Configuration
```dockerfile
# Multi-stage build for production
FROM [base-image] AS builder

WORKDIR /app

# Copy dependency files
COPY [dependency-files] ./

# Install dependencies
RUN [install-command]

# Copy source code
COPY . .

# Build application
RUN [build-command]

# Production stage
FROM [production-base] AS production

WORKDIR /app

# Copy built application
COPY --from=builder /app/[build-output] ./

# Expose port
EXPOSE [port]

# Start application
CMD ["[start-command]"]
```

## Documentation Standards

### README.md Structure
```markdown
# Project Name

Brief description of the project and its purpose.

## Quick Start

```bash
# Install dependencies
make install

# Start development server
make dev

# Build for production
make build
```

## Project Structure

Brief overview of key directories and their purposes.

## Development

### Prerequisites
- Runtime requirements
- Development tools
- Environment setup

### Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `API_URL` | Backend API endpoint | `http://localhost:3000` |
| `ENABLE_OFFLINE_MODE` | Enable offline functionality | `false` |

### Available Scripts
- `make dev` - Start development server
- `make build` - Build for production
- `make test` - Run test suite
- `make docker-build` - Build Docker image

## Testing

### Running Tests
```bash
# Run all tests
make test

# Run tests in watch mode
make test:watch

# Run tests with coverage
make test:coverage
```

## Deployment

### Docker Deployment
```bash
# Build image
make docker-build

# Run container
make docker-run
```

## Contributing

Guidelines for contributing to the project.

## License

Project license information.
```

### Architecture Documentation
Create an `architecture/` directory with:
- `README.md` - Architecture overview
- `system-design.md` - System design document
- `api-specs.md` - API specifications
- `database-schema.md` - Database design
- `deployment.md` - Deployment architecture
- `diagrams/` - Architecture diagrams (Mermaid, PlantUML, etc.)

## Testing Strategy

### Test Structure
```
tests/
├── README.md                 # Testing documentation
├── setupTests.[ext]         # Global test setup
├── [test-config].[ext]      # Test framework configuration
├── utils/
│   └── test-utils.[ext]     # Common test utilities
├── components/               # Mirror src/components structure
├── pages/                   # Mirror src/pages structure
├── hooks/                   # Mirror src/hooks structure
├── api/                     # Mirror src/api structure
├── contexts/                # Mirror src/contexts structure
└── mocks/                   # Mock data and handlers
```

### Test Categories
1. **Unit Tests**: Individual functions, components, and utilities
2. **Integration Tests**: Component interactions and API integration
3. **End-to-End Tests**: Complete user workflows
4. **Visual Regression Tests**: UI consistency checks

### Testing Patterns
```typescript
// Component Testing Pattern
describe('[ComponentName]', () => {
  it('renders with default props', () => {
    // Arrange
    // Act
    // Assert
  });

  it('handles user interactions', () => {
    // Test user interactions
  });

  it('displays loading states', () => {
    // Test loading states
  });

  it('handles error states', () => {
    // Test error handling
  });
});

// Hook Testing Pattern
describe('use[HookName]', () => {
  it('returns expected initial state', () => {
    // Test initial state
  });

  it('updates state correctly', () => {
    // Test state updates
  });

  it('handles errors gracefully', () => {
    // Test error handling
  });
});

// API Testing Pattern
describe('[ServiceName]', () => {
  it('successfully performs [operation]', async () => {
    // Test successful operations
  });

  it('handles API errors', async () => {
    // Test error scenarios
  });

  it('handles network failures', async () => {
    // Test network issues
  });
});
```

### Mocking Strategy
- **Global Mocks**: Browser APIs, storage, network
- **Component Mocks**: External dependencies, context providers
- **API Mocks**: HTTP responses, error scenarios
- **Data Mocks**: Test data factories and fixtures

## Design Principles

### Separation of Concerns
- **Presentation Layer**: UI components and styling
- **Business Logic Layer**: Custom hooks and services
- **Data Layer**: API clients and data management
- **State Management**: Context providers and state logic

### Single Responsibility Principle
- Each component should have one clear purpose
- Functions should perform a single operation
- Classes should represent one concept
- Modules should serve one domain

### Dependency Inversion
- Depend on abstractions, not concrete implementations
- Use interfaces for external dependencies
- Mock external services for testing
- Inject dependencies where possible

### Composition over Inheritance
- Prefer composition for code reuse
- Use higher-order components for shared behavior
- Create utility functions for common operations
- Build complex components from simple ones

## Code Organization

### Component Structure
```typescript
// 1. Imports (external libraries first, then internal)
import React from 'react';
import { externalLibrary } from 'external-package';
import { internalComponent } from '@/components/internal';

// 2. Type definitions
interface ComponentProps {
  // Props definition
}

// 3. Component definition
export const ComponentName: React.FC<ComponentProps> = ({ prop1, prop2 }) => {
  // 4. Hooks and state
  const [state, setState] = useState(initialValue);
  const customHook = useCustomHook();

  // 5. Event handlers
  const handleEvent = () => {
    // Event logic
  };

  // 6. Side effects
  useEffect(() => {
    // Side effect logic
  }, [dependencies]);

  // 7. Render logic
  return (
    <div>
      {/* JSX */}
    </div>
  );
};
```

### Hook Structure
```typescript
// 1. Imports
import { useState, useEffect } from 'react';

// 2. Type definitions
interface HookReturn {
  // Return type definition
}

// 3. Hook implementation
export function useHookName(dependencies): HookReturn {
  // 4. State management
  const [state, setState] = useState(initialValue);

  // 5. Side effects
  useEffect(() => {
    // Effect logic
  }, [dependencies]);

  // 6. Event handlers
  const handleAction = () => {
    // Action logic
  };

  // 7. Return values
  return {
    state,
    handleAction,
  };
}
```

### Service Structure
```typescript
// 1. Imports
import { apiClient } from './apiClient';

// 2. Type definitions
interface ServiceRequest {
  // Request type
}

interface ServiceResponse {
  // Response type
}

// 3. Service implementation
export class ServiceName {
  static async performAction(data: ServiceRequest): Promise<ServiceResponse> {
    try {
      const response = await apiClient.post('/endpoint', data);
      return response.data;
    } catch (error) {
      throw new ServiceError('Operation failed', error);
    }
  }
}
```

## API Design Patterns

### Client-Side API Layer
```typescript
// Base API client
export class ApiClient {
  private baseURL: string;
  private timeout: number;

  constructor(config: ApiConfig) {
    this.baseURL = config.baseURL;
    this.timeout = config.timeout || 10000;
  }

  async request<T>(options: RequestOptions): Promise<T> {
    // Request implementation with error handling
  }
}

// Domain-specific API services
export class UserService {
  static async getUsers(): Promise<User[]> {
    // Implementation
  }

  static async createUser(data: CreateUserRequest): Promise<User> {
    // Implementation
  }
}
```

### Error Handling Pattern
```typescript
export class ApiError extends Error {
  constructor(
    message: string,
    public status?: number,
    public data?: unknown,
    public isOffline: boolean = false
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Usage in services
try {
  const response = await apiClient.get('/endpoint');
  return response.data;
} catch (error) {
  if (error instanceof ApiError) {
    // Handle API-specific errors
  } else {
    // Handle unexpected errors
  }
}
```

### Request/Response Patterns
```typescript
// Standard request/response interfaces
interface ApiRequest<T = unknown> {
  data?: T;
  params?: Record<string, string | number | boolean>;
}

interface ApiResponse<T = unknown> {
  data: T;
  message?: string;
  status: number;
}

interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}
```

## State Management

### Context Pattern
```typescript
// Context definition
interface AppContextType {
  state: AppState;
  actions: AppActions;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider implementation
export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, setState] = useState<AppState>(initialState);

  const actions = {
    updateState: (updates: Partial<AppState>) => {
      setState(prev => ({ ...prev, ...updates }));
    },
    // Other actions
  };

  return (
    <AppContext.Provider value={{ state, actions }}>
      {children}
    </AppContext.Provider>
  );
};

// Hook for consuming context
export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};
```

### State Organization
- **Global State**: User authentication, app configuration
- **Domain State**: Business logic state (users, projects, etc.)
- **UI State**: Component-specific state (modals, forms, etc.)
- **Cache State**: API response caching and synchronization

## Error Handling

### Error Types
```typescript
// Base error class
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode?: number
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// Specific error types
export class ValidationError extends AppError {
  constructor(message: string, public field?: string) {
    super(message, 'VALIDATION_ERROR');
  }
}

export class NetworkError extends AppError {
  constructor(message: string) {
    super(message, 'NETWORK_ERROR');
  }
}
```

### Error Handling Strategy
1. **Prevention**: Input validation, type checking
2. **Detection**: Try-catch blocks, error boundaries
3. **Recovery**: Retry mechanisms, fallback states
4. **Reporting**: Error logging, user feedback

### Error Boundaries
```typescript
export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: undefined };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log error to monitoring service
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <ErrorFallback error={this.state.error} />;
    }

    return this.props.children;
  }
}
```

## Security Considerations

### Authentication & Authorization
- Implement proper token management
- Use secure storage for sensitive data
- Validate user permissions on both client and server
- Implement session timeout and refresh mechanisms

### Input Validation
- Validate all user inputs
- Sanitize data before processing
- Use type-safe interfaces for data structures
- Implement CSRF protection where applicable

### Data Protection
- Encrypt sensitive data in transit and at rest
- Implement proper CORS policies
- Use HTTPS for all communications
- Follow OWASP security guidelines

## Performance Guidelines

### Code Splitting
- Implement lazy loading for routes
- Split large components into smaller chunks
- Use dynamic imports for heavy dependencies
- Optimize bundle size with tree shaking

### Caching Strategy
- Cache API responses appropriately
- Implement memoization for expensive calculations
- Use React.memo for component optimization
- Implement proper cache invalidation

### Monitoring & Metrics
- Track application performance metrics
- Monitor API response times
- Implement error tracking and reporting
- Use performance profiling tools

### Optimization Techniques
- Minimize re-renders with proper dependency arrays
- Use virtual scrolling for large lists
- Implement debouncing for user inputs
- Optimize images and assets

## Environment Configuration

### Environment Variables
```bash
# Development
NODE_ENV=development
API_URL=http://localhost:3000
ENABLE_OFFLINE_MODE=false

# Production
NODE_ENV=production
API_URL=https://api.example.com
ENABLE_OFFLINE_MODE=false
```

### Configuration Management
- Use environment-specific configuration files
- Validate required environment variables
- Provide sensible defaults for optional variables
- Document all configuration options

## Deployment Guidelines

### Containerization
- Use multi-stage builds for production
- Minimize container image size
- Implement health checks
- Use non-root users in containers

### CI/CD Pipeline
- Automated testing on every commit
- Code quality checks (linting, formatting)
- Security scanning
- Automated deployment to staging/production

### Monitoring & Logging
- Implement structured logging
- Set up application monitoring
- Configure error alerting
- Track performance metrics

---

## Implementation Notes

### Language-Specific Adaptations
- **TypeScript**: Use strict type checking and interfaces
- **JavaScript**: Implement JSDoc for type documentation
- **Python**: Use type hints and dataclasses
- **Rust**: Leverage strong type system and error handling
- **Go**: Use interfaces and structured error handling

### Framework Considerations
- **React**: Follow hooks-first approach and functional components
- **Vue**: Use composition API and proper component structure
- **Angular**: Follow dependency injection and module patterns
- **Svelte**: Leverage reactive statements and stores

### Testing Framework Adaptations
- **Jest/Vitest**: Use describe/it blocks and proper mocking
- **PyTest**: Use fixtures and parametrized tests
- **Rust**: Use #[cfg(test)] and proper test organization
- **Go**: Use table-driven tests and proper test naming

This document serves as a comprehensive guide for maintaining consistency across all projects, regardless of the technology stack used. 
