import { render } from '@testing-library/react';
import App from '../App'; // Adjust import based on your App component

test('renders without crashing', () => {
  render(<App />);
});
