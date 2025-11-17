'use client';

import { AxiosError } from 'axios';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { FormEvent, useState } from 'react';

import apiClient from '@/lib/api';
import { setAuthTokens } from '@/lib/auth';

const userTypes = [
  { value: 'individual', label: 'Individual' },
  { value: 'fleet_manager', label: 'Fleet Manager' }
];

export default function RegisterPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [userType, setUserType] = useState(userTypes[0].value);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setError(null);

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);

    try {
      await apiClient.post('/auth/register/', {
        username: email,
        email,
        password,
        name,
        account_type: userType
      });

      const tokenResponse = await apiClient.post('/auth/token/', {
        username: email,
        password
      });
      setAuthTokens(tokenResponse.data.access, tokenResponse.data.refresh);
      router.push('/dashboard');
    } catch (err) {
      const message =
        err instanceof AxiosError && err.response?.data?.detail
          ? `Registration failed: ${err.response.data.detail}`
          : 'Unable to create your account right now.';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-charcoal/80 to-black flex items-center justify-center py-16 px-4">
      <div className="w-full max-w-lg bg-white/90 backdrop-blur rounded-3xl p-8 shadow-2xl border border-white/60">
        <p className="text-sm uppercase tracking-[0.6em] text-gray-500 mb-4">Autopredator</p>
        <h1 className="text-3xl font-bold text-charcoal mb-2">Create your account</h1>
        <p className="text-gray-600 mb-6">
          Join powerful AI insights, fleet tracking, and marketplace tools in one place.
        </p>

        <form onSubmit={handleSubmit} className="grid gap-4">
          <label className="block text-sm font-medium text-gray-700">
            Full name
            <input
              type="text"
              value={name}
              onChange={event => setName(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="Anjali Sharma"
            />
          </label>

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

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <label className="block text-sm font-medium text-gray-700">
              Password
              <input
                type="password"
                minLength={8}
                value={password}
                onChange={event => setPassword(event.target.value)}
                required
                className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
                placeholder="••••••••"
              />
            </label>
            <label className="block text-sm font-medium text-gray-700">
              Confirm password
              <input
                type="password"
                minLength={8}
                value={confirmPassword}
                onChange={event => setConfirmPassword(event.target.value)}
                required
                className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
                placeholder="Re-enter password"
              />
            </label>
          </div>

          <label className="block text-sm font-medium text-gray-700">
            Account type
            <select
              value={userType}
              onChange={event => setUserType(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-gray-300 px-4 py-3 focus:border-blue focus:outline-none"
            >
              {userTypes.map(type => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </label>

          {error && <p className="text-sm text-red-600 font-medium">{error}</p>}

          <button
            type="submit"
            disabled={loading}
            className="w-full btn-primary text-base font-semibold flex items-center justify-center gap-2"
          >
            {loading ? 'Creating account…' : 'Register'}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-gray-500">
          Already have an account?{' '}
          <Link href="/login" className="text-charcoal font-semibold hover:text-blue">
            Sign in
          </Link>
        </p>
      </div>
    </div>
  );
}
