import axios, { AxiosError, AxiosRequestConfig } from 'axios';

import { API_BASE_URL } from './utils';
import { getAccessToken, getRefreshToken, redirectToLogin, setAuthTokens } from './auth';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

interface RetryRequestConfig extends AxiosRequestConfig {
  _retry?: boolean;
}

let refreshPromise: Promise<string> | null = null;

const attachAccessToken = (config: AxiosRequestConfig) => {
  const token = getAccessToken();
  if (token) {
    config.headers = {
      ...(config.headers || {}),
      Authorization: `Bearer ${token}`
    };
  }
  return config;
};

const refreshAccessToken = async (): Promise<string> => {
  if (refreshPromise) {
    return refreshPromise;
  }

  const refreshToken = getRefreshToken();
  if (!refreshToken) {
    throw new Error('Missing refresh token');
  }

  refreshPromise = axios
    .post(
      `${API_BASE_URL}/auth/token/refresh/`,
      { refresh: refreshToken },
      { headers: { 'Content-Type': 'application/json' } }
    )
    .then(response => {
      const { access, refresh } = response.data;
      if (!access || !refresh) {
        throw new Error('Unable to refresh token');
      }
      setAuthTokens(access, refresh);
      return access;
    })
    .finally(() => {
      refreshPromise = null;
    });

  return refreshPromise;
};

apiClient.interceptors.request.use(attachAccessToken);

apiClient.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as RetryRequestConfig | undefined;
    if (error.response?.status === 401 && originalRequest && !originalRequest._retry) {
      try {
        const newAccessToken = await refreshAccessToken();
        originalRequest._retry = true;
        originalRequest.headers = {
          ...(originalRequest.headers || {}),
          Authorization: `Bearer ${newAccessToken}`
        };
        return apiClient(originalRequest);
      } catch {
        redirectToLogin();
        return Promise.reject(error);
      }
    }

    if (error.response?.status === 403) {
      redirectToLogin();
    }

    return Promise.reject(error);
  }
);

export default apiClient;
