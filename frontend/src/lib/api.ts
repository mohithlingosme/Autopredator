import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api',
  timeout: 10000,
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;

// Journal API functions
export const journalApi = {
  // List journal entries
  getEntries: (params?: { page?: number; limit?: number; search?: string }) =>
    api.get('/journal', { params }),

  // Get single entry
  getEntry: (id: string) => api.get(`/journal/${id}`),

  // Create new entry
  createEntry: (data: any) => api.post('/journal', data),

  // Update entry
  updateEntry: (id: string, data: any) => api.put(`/journal/${id}`, data),

  // Delete entry
  deleteEntry: (id: string) => api.delete(`/journal/${id}`),

  // Upload files
  uploadFiles: (files: File[]) => {
    const formData = new FormData();
    files.forEach(file => formData.append('files', file));
    return api.post('/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
};
