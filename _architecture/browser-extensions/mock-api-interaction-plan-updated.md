# Mock API Implementation & Extension-Web App Interaction Plan

## Overview
This document outlines the mock API structure and interaction patterns between the Deal Scale browser extension and the native web application (`app.leadorchestra.com`). The mock implementation will simulate real API behavior for development and testing.

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

-- Conversations table (for multi-channel conversation threading)
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  lead_id UUID REFERENCES leads(id),
  channel VARCHAR(50) NOT NULL, -- 'sms', 'social', 'phone', 'email', 'extension'
  channel_id VARCHAR(255), -- External channel identifier
  platform VARCHAR(100), -- 'twilio', 'linkedin', 'zoom', etc.
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Conversation Messages (detailed message tracking per channel)
CREATE TABLE conversation_messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id),
  lead_id UUID REFERENCES leads(id),
  direction VARCHAR(20) NOT NULL, -- 'inbound', 'outbound'
  content TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'sent', -- 'sent', 'delivered', 'read', 'failed'
  metadata JSONB, -- sentiment, intent, entities, etc.
  created_at TIMESTAMP DEFAULT NOW()
);

-- Suggestions table (AI-powered suggestions)
CREATE TABLE suggestions (
  id UUID PRIMARY KEY,
  lead_id UUID REFERENCES leads(id),
  content TEXT NOT NULL,
  suggestion_type VARCHAR(50) DEFAULT 'reply',
  channel VARCHAR(50), -- Channel-specific suggestions
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

-- Channel Integrations (for third-party service connections)
CREATE TABLE channel_integrations (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id),
  type VARCHAR(50) NOT NULL, -- 'sms', 'social', 'phone', 'email'
  platform VARCHAR(100) NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  configuration JSONB NOT NULL,
  last_sync TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
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

### Conversations API

```typescript
// GET /api/leads/{lead_id}/conversations
interface GetConversationsResponse {
  conversations: Conversation[];
  total_messages: number;
  last_activity: string;
  channel_summary: ChannelSummary;
}

// POST /api/leads/{lead_id}/conversations
interface CreateConversationRequest {
  channel: 'sms' | 'social' | 'phone' | 'email' | 'extension';
  channel_id?: string; // External channel identifier
  message: string;
  metadata?: {
    platform?: string; // 'twilio', 'linkedin', 'phone', etc.
    direction?: 'inbound' | 'outbound';
    delivery_status?: 'sent' | 'delivered' | 'read' | 'failed';
  };
}

// WebSocket event for real-time conversation updates
interface ConversationUpdateEvent {
  type: 'new_message' | 'status_update' | 'typing_indicator';
  lead_id: string;
  conversation_id: string;
  data: any;
}
```

### Channel Integration Types

```typescript
interface ChannelIntegration {
  id: string;
  type: 'sms' | 'social' | 'phone' | 'email';
  platform: string; // 'twilio', 'linkedin', 'zoom', etc.
  status: 'active' | 'inactive' | 'error';
  configuration: Record<string, any>;
  last_sync: string;
}

interface ConversationMessage {
  id: string;
  conversation_id: string;
  lead_id: string;
  channel: string;
  platform: string;
  direction: 'inbound' | 'outbound';
  content: string;
  timestamp: string;
  status: 'sent' | 'delivered' | 'read' | 'failed';
  metadata: {
    sentiment?: 'positive' | 'neutral' | 'negative';
    intent?: string;
    entities?: string[];
    action_items?: string[];
  };
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

### 2. Multi-Channel Conversation Management

```typescript
// Conversation service for handling multiple channels
class ConversationService {
  async sendMessage(leadId: string, message: string, channel: string): Promise<void> {
    // 1. Create conversation record
    const conversation = await apiClient.post(`/leads/${leadId}/conversations`, {
      channel,
      message,
      metadata: {
        platform: this.getPlatform(channel),
        direction: 'outbound'
      }
    });

    // 2. Update local conversation thread
    await this.updateLocalConversation(leadId, conversation);

    // 3. Handle channel-specific sending logic
    await this.sendToChannel(conversation, message);
  }

  async receiveMessage(channelMessage: ExternalMessage): Promise<void> {
    // 1. Identify or create lead
    const lead = await this.identifyLead(channelMessage);

    // 2. Create conversation record
    await apiClient.post(`/leads/${lead.id}/conversations`, {
      channel: channelMessage.channel,
      message: channelMessage.content,
      metadata: {
        platform: channelMessage.platform,
        direction: 'inbound',
        delivery_status: 'delivered'
      }
    });

    // 3. Update extension UI
    this.showNewMessageNotification(lead.id);
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

    this.eventSource.addEventListener('conversation_update', (event) => {
      const update = JSON.parse(event.data);
      this.handleConversationUpdate(update);
    });
  }

  private handleConversationUpdate(update: ConversationUpdate): void {
    // Update local storage
    localStorage.set(`conversation_${update.lead_id}`, update.data);

    // Notify UI components
    window.dispatchEvent(new CustomEvent('conversation-updated', {
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

2. **Multi-Channel Response**
   ```typescript
   // Quick response from extension popup
   const response = await conversationService.sendMessage(leadId, message, 'sms');
   // Show immediate feedback in extension
   this.showMessageSentConfirmation();
   ```

### Web App Integration Points

1. **Unified Conversation View**
   ```typescript
   // Web app shows all conversations across channels
   const conversations = await apiClient.get(`/leads/${leadId}/conversations`);
   const unifiedThread = this.mergeConversationsByTimestamp(conversations);
   ```

2. **Channel Analytics**
   ```typescript
   // Web app provides channel performance insights
   const analytics = await apiClient.get('/analytics/channels', {
     lead_id: leadId,
     date_range: 'last_30_days'
   });
   ```

## Mock Data Examples

### Sample Conversation Thread
```typescript
const mockConversationThread = {
  lead_id: 'lead_123',
  conversations: [
    {
      id: 'conv_sms_001',
      channel: 'sms',
      platform: 'twilio',
      messages: [
        {
          id: 'msg_001',
          direction: 'inbound',
          content: 'Hi, interested in your pricing',
          timestamp: '2024-01-15T10:30:00Z',
          status: 'delivered',
          metadata: { sentiment: 'positive', intent: 'pricing_inquiry' }
        },
        {
          id: 'msg_002',
          direction: 'outbound',
          content: 'Great! I can share our pricing tiers.',
          timestamp: '2024-01-15T10:32:00Z',
          status: 'read'
        }
      ]
    },
    {
      id: 'conv_linkedin_001',
      channel: 'social',
      platform: 'linkedin',
      messages: [
        {
          id: 'msg_003',
          direction: 'inbound',
          content: 'Thanks for the info. Can we schedule a call?',
          timestamp: '2024-01-15T14:20:00Z'
        }
      ]
    }
  ],
  channel_summary: {
    sms: { count: 2, last_activity: '2024-01-15T10:32:00Z' },
    social: { count: 1, last_activity: '2024-01-15T14:20:00Z' }
  }
};
```

## Development Workflow

### Setting Up Mock Server
1. Use JSON Server, MSW, or Mirage.js for API mocking
2. Seed database with realistic conversation data across channels
3. Implement channel-specific response simulation

### Testing Integration
1. Unit tests for conversation management
2. Integration tests for multi-channel flows
3. E2E tests across extension and web app with real-time updates

This mock implementation will allow us to develop and test the multi-channel conversation management before connecting to real third-party services, ensuring smooth integration when ready for production.
