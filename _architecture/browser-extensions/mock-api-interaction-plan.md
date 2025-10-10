# Mock API Implementation & Extension-Web App Interaction Plan

## Overview
This document outlines the mock API structure and interaction patterns between the Deal Scale browser extension and the native web application (`app.dealscale.io`). The mock implementation will simulate real API behavior for development and testing.

## Mock Database Schema

### PostgreSQL Tables Structure

```sql
-- Users table (for authentication and user management)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Organizations table (for multi-tenant architecture)
CREATE TABLE organizations (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  slug VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User Organizations (many-to-many relationship)
CREATE TABLE user_organizations (
  user_id UUID REFERENCES users(id),
  organization_id UUID REFERENCES organizations(id),
  role VARCHAR(50) DEFAULT 'member',
  PRIMARY KEY (user_id, organization_id)
);

-- Leads table (core business data)
CREATE TABLE leads (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id),
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  email VARCHAR(255),
  status lead_status_enum DEFAULT 'new',
  notes TEXT,
  ai_enabled BOOLEAN DEFAULT true,
  ai_confidence VARCHAR(50) DEFAULT 'needs_review',
  last_reply_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Messages table (conversation history)
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  lead_id UUID REFERENCES leads(id),
  author_type message_author_enum NOT NULL, -- 'lead', 'ai', 'rep', 'system'
  author_name VARCHAR(255),
  body TEXT NOT NULL,
  sentiment sentiment_enum DEFAULT 'neutral', -- 'positive', 'neutral', 'negative'
  label VARCHAR(100),
  metadata JSONB, -- For additional message context
  created_at TIMESTAMP DEFAULT NOW()
);

-- Suggestions table (AI-powered suggestions)
CREATE TABLE suggestions (
  id UUID PRIMARY KEY,
  lead_id UUID REFERENCES leads(id),
  content TEXT NOT NULL,
  suggestion_type VARCHAR(50) DEFAULT 'reply',
  is_used BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Participants table (for group handoffs)
CREATE TABLE participants (
  id UUID PRIMARY KEY,
  lead_id UUID REFERENCES leads(id),
  name VARCHAR(255) NOT NULL,
  role VARCHAR(100),
  added_at TIMESTAMP DEFAULT NOW()
);

-- Sync Queue table (for offline sync handling)
CREATE TABLE sync_queue (
  id UUID PRIMARY KEY,
  extension_id VARCHAR(255), -- Browser extension instance identifier
  operation VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete'
  table_name VARCHAR(100) NOT NULL,
  record_id UUID NOT NULL,
  data JSONB NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  attempts INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Mock API Endpoints

### Authentication Endpoints

```typescript
// POST /api/auth/login
interface LoginRequest {
  email: string;
  password: string;
  extension_id?: string; // For extension authentication
}

interface LoginResponse {
  user: User;
  token: string;
  refresh_token: string;
  organization: Organization;
}

// POST /api/auth/refresh
interface RefreshTokenRequest {
  refresh_token: string;
}
```

### Leads API

```typescript
// GET /api/leads?organization_id={id}&limit=50&offset=0
interface GetLeadsResponse {
  leads: Lead[];
  total: number;
  has_more: boolean;
}

// POST /api/leads
interface CreateLeadRequest {
  name: string;
  phone?: string;
  email?: string;
  notes?: string;
  source?: 'extension' | 'web' | 'api';
  metadata?: Record<string, any>;
}

// PUT /api/leads/{id}
interface UpdateLeadRequest {
  name?: string;
  phone?: string;
  status?: LeadStatus;
  notes?: string;
  ai_enabled?: boolean;
}

// DELETE /api/leads/{id}
interface DeleteLeadResponse {
  success: boolean;
}
```

### Messages API

```typescript
// GET /api/leads/{lead_id}/messages
interface GetMessagesResponse {
  messages: Message[];
  has_more: boolean;
}

// POST /api/leads/{lead_id}/messages
interface CreateMessageRequest {
  body: string;
  author_type: 'ai' | 'rep' | 'system';
  sentiment?: 'positive' | 'neutral' | 'negative';
  label?: string;
  metadata?: Record<string, any>;
}
```

### Suggestions API

```typescript
// GET /api/leads/{lead_id}/suggestions
interface GetSuggestionsResponse {
  suggestions: Suggestion[];
}

// POST /api/suggestions/generate
interface GenerateSuggestionsRequest {
  lead_id: string;
  context?: string;
  count?: number;
}
```

## Browser Extension Integration Patterns

### 1. Authentication Flow

```typescript
// Extension authentication sequence
class ExtensionAuthService {
  async authenticate(email: string, password: string): Promise<AuthResult> {
    // 1. Call login API with extension_id
    const response = await apiClient.post('/auth/login', {
      email,
      password,
      extension_id: this.getExtensionId()
    });

    // 2. Store tokens securely in extension storage
    await this.storeTokens(response.token, response.refresh_token);

    // 3. Initialize data sync
    await syncService.startPeriodicSync();

    return response;
  }

  private getExtensionId(): string {
    // Generate unique extension instance ID
    return `ext_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

### 2. Data Synchronization Strategy

```typescript
// Sync service for offline/online handling
class LeadSyncService {
  private syncQueue: SyncOperation[] = [];
  private isOnline: boolean = navigator.onLine;

  async syncLead(lead: Lead, operation: 'create' | 'update' | 'delete'): Promise<void> {
    // Always store locally first (immediate UI feedback)
    await localStorage.set(`lead_${lead.id}`, lead);

    if (this.isOnline) {
      // Attempt immediate sync
      try {
        await this.syncToServer(lead, operation);
      } catch (error) {
        // Queue for later if offline or error
        this.queueForSync(lead, operation, error);
      }
    } else {
      // Queue for when back online
      this.queueForSync(lead, operation);
    }
  }

  private async syncToServer(lead: Lead, operation: string): Promise<void> {
    switch (operation) {
      case 'create':
        await apiClient.post('/leads', lead);
        break;
      case 'update':
        await apiClient.put(`/leads/${lead.id}`, lead);
        break;
      case 'delete':
        await apiClient.delete(`/leads/${lead.id}`);
        break;
    }
  }
}
```

### 3. Real-time Communication

```typescript
// WebSocket/SSE integration for real-time updates
class RealtimeService {
  private eventSource?: EventSource;

  connect(): void {
    this.eventSource = new EventSource('/api/events', {
      headers: {
        'Authorization': `Bearer ${this.getAuthToken()}`
      }
    });

    this.eventSource.addEventListener('lead_updated', (event) => {
      const leadUpdate = JSON.parse(event.data);
      this.handleLeadUpdate(leadUpdate);
    });
  }

  private handleLeadUpdate(update: LeadUpdate): void {
    // Update local storage
    localStorage.set(`lead_${update.id}`, update.data);

    // Notify UI components
    window.dispatchEvent(new CustomEvent('lead-updated', {
      detail: update
    }));
  }
}
```

## Interaction Patterns: Extension vs Web App

### Extension-Specific Behaviors

1. **Lead Capture**
   ```typescript
   // Extension captures lead from current webpage
   const lead = await extractLeadFromPage();
   lead.source = 'extension';
   lead.metadata = { url: window.location.href, timestamp: Date.now() };

   await leadSyncService.syncLead(lead, 'create');
   ```

2. **Offline Queue Management**
   ```typescript
   // Handle offline scenarios
   window.addEventListener('online', async () => {
     await syncService.processQueue();
   });

   // Periodic sync attempts
   setInterval(() => {
     if (navigator.onLine) {
       syncService.processQueue();
     }
   }, 30000); // Every 30 seconds
   ```

### Web App Integration Points

1. **Shared Lead Management**
   ```typescript
   // Web app shows all leads (from extension + manual entry)
   const allLeads = await apiClient.get('/leads');
   const extensionLeads = allLeads.filter(lead => lead.source === 'extension');
   const manualLeads = allLeads.filter(lead => lead.source !== 'extension');
   ```

2. **Advanced Analytics**
   ```typescript
   // Web app provides insights not available in extension
   const analytics = await apiClient.get('/analytics', {
     start_date: '2024-01-01',
     end_date: '2024-12-31',
     group_by: 'source' // extension vs web
   });
   ```

## Mock Data Examples

### Sample Lead Object
```typescript
const mockLead: Lead = {
  id: 'lead_123',
  organization_id: 'org_456',
  name: 'John Smith',
  phone: '+1555123456',
  email: 'john@company.com',
  status: 'interested',
  notes: 'Interested in enterprise pricing',
  ai_enabled: true,
  ai_confidence: 'confident',
  last_reply_at: '2024-01-15T10:30:00Z',
  messages: [...],
  suggestions: [...],
  participants: [],
  is_group_chat: false,
  source: 'extension',
  metadata: {
    captured_url: 'https://example.com/contact',
    extension_version: '1.0.0'
  }
};
```

### Sample API Response
```typescript
// GET /api/leads response
{
  "leads": [mockLead, ...],
  "total": 150,
  "has_more": true,
  "filters_applied": {
    "status": ["new", "interested"],
    "source": "extension"
  }
}
```

## Development Workflow

### Setting Up Mock Server
1. Use JSON Server, MSW, or Mirage.js for API mocking
2. Seed database with realistic test data
3. Implement rate limiting and error scenarios

### Testing Integration
1. Unit tests for API client
2. Integration tests for sync workflows
3. E2E tests across extension and web app

This mock implementation will allow us to develop and test the hybrid architecture before connecting to the real PostgreSQL backend, ensuring smooth integration when ready for production.
