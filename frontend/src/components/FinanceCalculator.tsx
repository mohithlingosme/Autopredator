'use client';

import { useMemo, useState } from 'react';

interface FinanceCalculatorProps {
  price: number;
}

const calculateEmi = (amount: number, rate: number, tenure: number) => {
  const monthlyRate = rate / (12 * 100);
  const emi = (amount * monthlyRate * Math.pow(1 + monthlyRate, tenure)) / (Math.pow(1 + monthlyRate, tenure) - 1);
  return isFinite(emi) ? emi : 0;
};

export default function FinanceCalculator({ price }: FinanceCalculatorProps) {
  const [amount, setAmount] = useState(price);
  const [interest, setInterest] = useState(9.5);
  const [tenure, setTenure] = useState(60);

  const emi = useMemo(() => calculateEmi(amount, interest, tenure), [amount, interest, tenure]);

  return (
    <div className="space-y-4">
      <div>
        <label className="text-sm text-gray-600">Loan Amount</label>
        <input
          type="number"
          className="w-full border rounded-md px-3 py-2 mt-1"
          value={amount}
          onChange={event => setAmount(Number(event.target.value))}
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="text-sm text-gray-600">Interest Rate %</label>
          <input
            type="number"
            className="w-full border rounded-md px-3 py-2 mt-1"
            value={interest}
            onChange={event => setInterest(Number(event.target.value))}
          />
        </div>
        <div>
          <label className="text-sm text-gray-600">Tenure (months)</label>
          <input
            type="number"
            className="w-full border rounded-md px-3 py-2 mt-1"
            value={tenure}
            onChange={event => setTenure(Number(event.target.value))}
          />
        </div>
      </div>
      <div className="bg-gray-50 rounded-lg p-4">
        <p className="text-sm text-gray-600">Estimated EMI</p>
        <p className="text-2xl font-bold text-blue mt-1">Rs {emi.toFixed(0)}/mo</p>
      </div>
    </div>
  );
}
