# Workflow: Converting Mock Data to Real API Calls

## Overview
This document outlines the steps to replace mock/faker data with real API calls in the Next.js application, ensuring all data is properly persisted to the database using the correct API connection pattern.

## Prerequisites
- Backend API is running and accessible
- Authentication is properly set up
- API route handlers are configured in `/src/app/api`
- Environment variables are properly set (NEXT_PUBLIC_API_URL)

## Step 1: Identify Mock Data Usage

1. Search for files using mock data patterns:
   - `faker.`
   - `mock`
   - Hardcoded arrays/objects that should come from the API

2. Common locations to check:
   - Page components
   - Custom hooks
   - Utility functions
   - Test files

## Step 2: Set Up API Integration

### API Route Handler Pattern

All API calls should be made through Next.js route handlers that proxy requests to the backend server. This provides several benefits:
- Centralized API request handling
- Server-side rate limiting
- Environment-specific configurations
- Better security (hiding backend details from client)

#### Example API Route Handler (`/src/app/api/example/route.ts`):

```typescript
import { NextResponse } from 'next/server';
import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';

// Environment-based configuration
const isDevelopment = process.env.NODE_ENV === 'development';

// Rate limiting middleware
const limiter = rateLimit({
  windowMs: isDevelopment ? 60 * 1000 : 15 * 60 * 1000,
  max: isDevelopment ? 20 : 5,
  message: 'Too many requests, please try again later',
  skip: () => isDevelopment,
});

// Request throttling
const speedLimiter = slowDown({
  windowMs: isDevelopment ? 60 * 1000 : 15 * 60 * 1000,
  delayAfter: isDevelopment ? 10 : 3,
  delayMs: isDevelopment ? 100 : 500,
  skip: () => isDevelopment,
});

// Apply rate limiting
const applyRateLimit = (req: Request) => {
  return new Promise((resolve, reject) => {
    // @ts-ignore - Express types don't match Next.js types
    limiter(req, {}, (err) => {
      if (err) return reject(err);
      // @ts-ignore
      speedLimiter(req, {}, (err) => {
        if (err) return reject(err);
        resolve(true);
      });
    });
  });
};

export async function GET() {
  try {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3005';
    const response = await fetch(`${apiUrl}/api/endpoint`, {
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json();
    
    if (!response.ok) {
      return NextResponse.json(
        { error: data.detail || 'Request failed' },
        { status: response.status }
      );
    }

    return NextResponse.json(data);
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

## Step 3: Replace Mock Data with API Calls

### Client-Side Data Fetching

When fetching data from client components, call the API route instead of using mock data:

```typescript
const fetchData = async () => {
  try {
    const response = await fetch('/api/example');
    if (!response.ok) throw new Error('Failed to fetch data');
    const data = await response.json();
    setData(data);
  } catch (error) {
    console.error('Error fetching data:', error);
    setError('Failed to load data');
  } finally {
    setIsLoading(false);
  }
};
```

## Step 4: Update the Test Route

Update the test route to use the API route pattern:

```typescript
// src/app/test-route/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function TestRoute() {
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const router = useRouter();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('/api/example');
        if (!response.ok) throw new Error('Failed to fetch data');
        const result = await response.json();
        setData(result);
      } catch (err) {
        console.error('Error fetching data:', err);
        setError('Failed to load data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  // ... rest of the component
}
```

## Step 5: Environment Configuration

Make sure your environment variables are properly configured in `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3005
```

## Best Practices

1. **Error Handling**: Always handle API errors gracefully
2. **Type Safety**: Use TypeScript interfaces for API responses
3. **Loading States**: Show loading indicators during API calls
4. **Rate Limiting**: Implement rate limiting in API routes
5. **Environment Variables**: Use environment variables for configuration
6. **Logging**: Log errors for debugging in development
7. **Security**: Never expose sensitive data in client-side code

## Common Issues and Solutions

1. **CORS Issues**: Ensure your backend has proper CORS configuration
2. **Environment Variables**: Make sure they're properly loaded
3. **Type Mismatches**: Keep TypeScript interfaces in sync with API responses
4. **Rate Limiting**: Adjust limits based on your application's needs

## Next Steps

1. Update existing API routes to follow this pattern
2. Replace all mock data with real API calls
3. Add proper error boundaries
4. Implement proper loading states
5. Add unit and integration tests
