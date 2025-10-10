# Deal Scale System Architecture Overview
browse this for our offical api docs: https://api.dealscale.io/docs
## System Modules

Deal Scale consists of four distinct modules that work together to provide a comprehensive lead management solution:

### 1. Landing Page (`dealscale.io` or similar)
**Purpose**: Marketing and user acquisition
- **Technology**: Static site (possibly Next.js, React, or HTML/CSS)
- **Features**:
  - Product showcase and features
  - Pricing information
  - Customer testimonials
  - Contact forms
  - Blog/content sections
- **User Flow**: Visitors → Sign up → Redirect to app

### 2. Web Application (`app.dealscale.io`)
**Purpose**: Main user interface for lead management
- **Technology**: Next.js/React frontend with your specified stack
- **Features**:
  - Advanced lead management interface
  - Team collaboration tools
  - Analytics and reporting
  - Settings and configuration
  - Integration management
- **User Flow**: Authenticated users → Full lead management experience

### 3. API Backend (`api.dealscale.io`)
**Purpose**: Data processing and persistence layer
- **Technology**: FastAPI/Python with PostgreSQL as specified
- **Features**:
  - Lead CRUD operations
  - AI processing for suggestions
  - User authentication and authorization
  - Real-time notifications
  - Integration webhooks
  - Analytics data processing

### 4. Browser Extension
**Purpose**: Lead capture and quick actions in browser context
- **Technology**: React/TypeScript extension using webextension-polyfill
- **Features**:
  - Lead capture from web pages
  - Quick lead actions (call, email, status updates)
  - Offline lead management
  - Sync with web application

## Module Interaction Patterns

### Data Flow Architecture

```
Internet/Websites
       ↓
Browser Extension (Lead Capture)
       ↓ (via API calls)
API Backend (api.dealscale.io)
       ↓ (WebSocket/real-time)
Web Application (app.dealscale.io)
       ↓ (Authentication/Analytics)
Landing Page (Marketing)
```

### Specific Interaction Examples

#### Lead Capture Flow
1. **Extension**: User visits website → Extension detects potential lead
2. **Extension**: Captures contact info and context from page
3. **Extension → API**: POST `/leads` with lead data and metadata
4. **API**: Processes and stores lead in PostgreSQL
5. **API → Web App**: Real-time notification via WebSocket
6. **Web App**: Updates UI to show new lead

#### Authentication Flow
1. **User visits app.dealscale.io**
2. **Web App**: Redirects to authentication
3. **API**: Handles OAuth/social login
4. **API**: Returns JWT tokens
5. **Web App**: Stores tokens and initializes user session
6. **Extension**: Detects authenticated user and syncs data

#### Analytics Flow
1. **Extension**: Captures lead source data and metadata
2. **Extension → API**: POST `/events` with interaction data
3. **API**: Processes analytics events
4. **Web App**: Queries `/analytics` endpoint for insights
5. **Web App**: Displays conversion funnels and performance metrics

## Technology Integration Points

### Shared Services
- **Authentication**: JWT tokens shared between web app and extension
- **Data Models**: Consistent TypeScript interfaces across all modules
- **Real-time Updates**: WebSocket connections for live synchronization

### Development Workflow
- **Monorepo Structure**: Single repository with multiple applications
- **Shared Libraries**: Common utilities, types, and validation schemas
- **CI/CD Pipeline**: Coordinated deployments across all modules

## Module-Specific Constraints

### Browser Extension Limitations (vs Other Modules)
- **Storage**: Limited local storage vs full PostgreSQL
- **Processing**: Cannot run AI models or complex business logic
- **UI**: Constrained popup interface vs full web application
- **Network**: Must handle offline scenarios gracefully

### API Backend Advantages
- **Scalability**: Handle multiple users and large datasets
- **Processing Power**: Run AI algorithms and complex analytics
- **Persistence**: Full database capabilities for data integrity
- **Integration**: Connect with external services and APIs

## Deployment Strategy

### Module Independence
- **Landing Page**: Can be deployed on static hosting (Netlify/Vercel)
- **Web Application**: Full-stack deployment with API integration
- **API Backend**: Independent scaling and database management
- **Browser Extension**: Published to Chrome Web Store/Firefox Add-ons

### Data Synchronization
- **Real-time**: WebSocket connections for immediate updates
- **Batch**: Periodic sync for offline extension data
- **Conflict Resolution**: Server-side resolution with timestamps
- **Backup**: Cross-module data redundancy

This modular architecture provides flexibility, scalability, and optimal user experience across different contexts while maintaining data consistency and feature parity.
