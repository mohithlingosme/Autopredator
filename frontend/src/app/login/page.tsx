'use client';

import { AxiosError } from 'axios';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { FormEvent, useState } from 'react';

import apiClient from '@/lib/api';
import { setAuthTokens } from '@/lib/auth';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const response = await apiClient.post('/auth/token/', {
        username: email,
        password
      });
      setAuthTokens(response.data.access, response.data.refresh);

      router.push('/dashboard');
    } catch (err) {
      const message =
        err instanceof AxiosError && err.response?.data?.detail
          ? `Login failed: ${err.response.data.detail}`
          : 'Unable to log you in right now.';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-charcoal/90 to-black flex items-center justify-center py-16 px-4">
      <div className="w-full max-w-md bg-white/90 backdrop-blur rounded-3xl p-8 shadow-2xl border border-white/60">
        <p className="text-sm uppercase tracking-[0.6em] text-gray-500 mb-4">Autopredator</p>
        <h1 className="text-3xl font-bold text-charcoal mb-2">Welcome back</h1>
        <p className="text-gray-600 mb-6">Sign in to continue managing your vehicles and AI insights.</p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <label className="block text-sm font-medium text-gray-700">
            Email
            <input
              type="email"
              value={email}
              onChange={event => setEmail(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="you@example.com"
            />
          </label>

          <label className="block text-sm font-medium text-gray-700">
            Password
            <input
              type="password"
              value={password}
              onChange={event => setPassword(event.target.value)}
              required
              minLength={8}
              className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="••••••••"
            />
          </label>

          {error && <p className="text-sm text-red-600 font-medium">{error}</p>}

          <button
            type="submit"
            className="w-full btn-primary text-base font-semibold flex items-center justify-center gap-2"
            disabled={loading}
          >
            {loading ? 'Signing in…' : 'Login'}
          </button>
        </form>

        <div className="mt-6 flex items-center justify-between text-sm text-gray-500">
          <Link href="/forgot-password" className="hover:text-charcoal transition-colors">
            Forgot password?
          </Link>
          <Link href="/register" className="font-semibold text-charcoal hover:text-blue transition-colors">
            Create account
          </Link>
        </div>
      </div>
    </div>
  );
}
