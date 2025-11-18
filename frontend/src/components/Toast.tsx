import React from 'react';
import { CheckCircle, XCircle, AlertCircle, Info } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface ToastProps {
  message: string;
  type?: 'success' | 'error' | 'warning' | 'info';
  onClose?: () => void;
}

export default function Toast({ message, type = 'info', onClose }: ToastProps) {
  const icons = {
    success: CheckCircle,
    error: XCircle,
    warning: AlertCircle,
    info: Info,
  };

  const colors = {
    success: 'bg-green-500',
    error: 'bg-red-500',
    warning: 'bg-yellow-500',
    info: 'bg-blue-500',
  };

  const Icon = icons[type];

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -50 }}
        className={`flex items-center p-4 rounded-lg shadow-lg text-white ${colors[type]}`}
      >
        <Icon className="h-5 w-5 mr-3" />
        <span className="flex-1">{message}</span>
        {onClose && (
          <button
            onClick={onClose}
            className="ml-3 p-1 rounded hover:bg-white/20"
            aria-label="Close toast"
          >
            <XCircle className="h-4 w-4" />
          </button>
        )}
      </motion.div>
    </AnimatePresence>
  );
}
