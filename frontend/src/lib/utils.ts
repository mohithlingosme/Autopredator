export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:5000';

export const fetcher = async <T>(path: string, init?: RequestInit): Promise<T> => {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers || {})
    },
    cache: init?.cache ?? 'no-store'
  });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  return response.json();
};

export const formatCurrency = (value?: number, currency = 'INR') => {
  if (!value) return 'Rs —';
  const formatter = new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0
  });
  return formatter.format(value).replace('₹', 'Rs');
};

export const formatPriceRange = (min?: number, max?: number, currency?: string) => {
  if (!min && !max) return 'Price on request';
  if (!max || min === max) {
    return formatCurrency(min || max, currency);
  }
  return `${formatCurrency(min, currency)} - ${formatCurrency(max, currency)}`;
};

export const classNames = (...classes: Array<string | undefined | false>) => classes.filter(Boolean).join(' ');
