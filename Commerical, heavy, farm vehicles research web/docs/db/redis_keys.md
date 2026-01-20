# Redis Key Plan

Key patterns and TTLs for the AutoPredator stack.

- `cache:listing:{listing_id}` (TTL: 10m) — denormalized listing payload for detail page.
- `cache:variant:{variant_id}` (TTL: 30m) — catalog variant with specs/features.
- `cache:price_history:{variant_id}:{city_id}` (TTL: 6h) — latest price + small history window.
- `lead:throttle:{org_id}:{buyer_phone}` (TTL: 5m) — dedupe/throttle incoming leads.
- `lead:queue` (list) — background processing queue for lead notifications.
- `session:user:{user_id}` (TTL: 24h) — short-lived user session/claims.
- `otp:{phone}` (TTL: 10m) — OTP validation for phone login/lead verification.
- `search:suggestions:{prefix}` (TTL: 1h) — cached search suggestion results.
- `fleet:vehicle:last_location:{vehicle_id}` (TTL: 15m) — last known GPS snapshot.
- `worker:locks:{resource}` (TTL: 2m) — distributed locks for cron/maintenance jobs.

Housekeeping:
- Prefer sets or sorted sets for counters/leaderboards (`metrics:*`), expire aggressively (24h).
- Use Redis as cache/queue only; no long-term storage. Keep max TTL <= 24h unless explicitly noted.
