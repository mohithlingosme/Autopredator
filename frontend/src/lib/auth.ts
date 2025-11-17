const ACCESS_TOKEN_KEY = 'autopredator_access_token';
const REFRESH_TOKEN_KEY = 'autopredator_refresh_token';

const isBrowser = () => typeof window !== 'undefined';

const readToken = (key: string) => (isBrowser() ? window.localStorage.getItem(key) : null);

export const getAccessToken = () => readToken(ACCESS_TOKEN_KEY);

export const getRefreshToken = () => readToken(REFRESH_TOKEN_KEY);

export const setAuthTokens = (accessToken: string, refreshToken: string) => {
  if (!isBrowser()) {
    return;
  }
  window.localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  window.localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
};

export const clearAuthTokens = () => {
  if (!isBrowser()) {
    return;
  }
  window.localStorage.removeItem(ACCESS_TOKEN_KEY);
  window.localStorage.removeItem(REFRESH_TOKEN_KEY);
};

export const redirectToLogin = () => {
  if (!isBrowser()) {
    return;
  }
  clearAuthTokens();
  window.location.href = '/login';
};
