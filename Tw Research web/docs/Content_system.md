# Content System

This document describes the content management system for articles, guides, and user-generated content.

## Content Types

### Article
- `id`: UUID
- `title`: String
- `slug`: String (unique)
- `content`: Rich Text (Markdown)
- `author_id`: Foreign Key (User)
- `status`: Enum (draft, published, archived)
- `published_at`: Timestamp
- `tags`: Array of Strings
- `seo_title`: String
- `seo_description`: String

### Guide
- Similar to Article but focused on how-to content
- Includes step-by-step instructions
- Category: Enum (maintenance, buying, safety, etc.)

### Review
- `id`: UUID
- `vehicle_id`: Foreign Key
- `user_id`: Foreign Key
- `rating`: Integer (1-5)
- `title`: String
- `content`: Text
- `pros`: Array of Strings
- `cons`: Array of Strings
- `verified`: Boolean

## Content Workflow

1. Draft creation
2. Review and editing
3. Approval process
4. Publishing
5. SEO optimization
6. Performance monitoring

## Versioning

All content changes are versioned:
- `content_version`: Increment on each edit
- `previous_version_id`: Link to previous version
- `change_summary`: Brief description of changes

## SEO Features

- Automatic meta tag generation
- Schema.org structured data
- Internal linking suggestions
- Related content recommendations
- Sitemap generation

## Moderation

- Content flagged for review
- Spam detection
- Fact-checking workflow
- User reporting system
