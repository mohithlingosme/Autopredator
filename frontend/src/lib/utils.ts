export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL ||
  process.env.REACT_APP_API_URL ||
  'http://localhost:8000/api';

export const formatCurrency = (value?: number, currency = 'INR') => {
  if (value == null) return 'Rs --';
  const formatter = new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0
  });
  return formatter.format(value);
};

export const formatPriceRange = (min?: number, max?: number, currency?: string) => {
  if (!min && !max) return 'Price on request';
  if (!max || min === max) {
    return formatCurrency(min || max, currency);
  }
  return `${formatCurrency(min, currency)} - ${formatCurrency(max, currency)}`;
};

export const classNames = (...classes: Array<string | undefined | false>) => classes.filter(Boolean).join(' ');
