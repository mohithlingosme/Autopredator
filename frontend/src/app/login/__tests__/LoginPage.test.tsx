import { render, screen } from '@testing-library/react';

import LoginPage from '@/app/login/page';

vi.mock('next/navigation', () => ({
  useRouter: () => ({ push: vi.fn() })
}));

describe('LoginPage', () => {
  it('renders input fields and login button', () => {
    render(<LoginPage />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  });
});
