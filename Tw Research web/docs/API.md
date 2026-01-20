# API Documentation

This document defines the API conventions for the Autopredator platform.

## Error Response Schema

All API errors follow this format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "must be a valid email address"
    }
  },
  "request_id": "req-12345"
}
```

Common error codes:
- `VALIDATION_ERROR`: Input validation failed
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `INTERNAL_ERROR`: Server error

## Pagination

Use cursor-based pagination for large datasets:

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "abc123",
    "has_more": true
  }
}
```

Query parameters:
- `limit`: Maximum items per page (default: 20, max: 100)
- `cursor`: Cursor for next page

## Filtering and Sorting

Filtering:
- Use query parameters like `?status=active&category=premium`
- Support operators: `eq`, `ne`, `gt`, `lt`, `gte`, `lte`, `in`, `contains`

Sorting:
- `?sort=created_at:desc,name:asc`
- Default sort if not specified

## Request ID / Correlation ID

Every request includes a unique `request_id` in the response. Use this for debugging and tracing requests across services.

Include `X-Request-ID` header in requests to maintain correlation.
