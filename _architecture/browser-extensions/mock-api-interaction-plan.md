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
