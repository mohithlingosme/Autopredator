import posthog from 'posthog-js';

const POSTHOG_KEY = process.env.NEXT_PUBLIC_POSTHOG_API_KEY;
const POSTHOG_HOST = process.env.NEXT_PUBLIC_POSTHOG_HOST || 'https://app.posthog.com';

let initialized = false;

export const initAnalytics = () => {
  if (initialized || typeof window === 'undefined' || !POSTHOG_KEY) {
    return;
  }

  posthog.init(POSTHOG_KEY, {
    api_host: POSTHOG_HOST,
    autocapture: true,
    capture_pageview: true,
    persistence: 'localStorage',
  });

  initialized = true;
};

export const trackEvent = (event: string, properties?: Record<string, unknown>) => {
  initAnalytics();
  if (!initialized) {
    return;
  }
  posthog.capture(event, properties);
};
