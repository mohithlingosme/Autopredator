import React from 'react';
import { motion } from 'framer-motion';
import Button from './Button';
import { AlertTriangle, RefreshCw } from 'lucide-react';

interface ErrorOverlayProps {
  isVisible: boolean;
  message?: string;
  onRetry?: () => void;
  onClose?: () => void;
}

export default function ErrorOverlay({
  isVisible,
  message = 'Something went wrong. Please try again.',
  onRetry,
  onClose
}: ErrorOverlayProps) {
  if (!isVisible) return null;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="bg-white rounded-lg p-6 shadow-xl max-w-md w-full mx-4"
      >
        <div className="flex items-center mb-4">
          <AlertTriangle className="h-6 w-6 text-red-500 mr-3" />
          <h3 className="text-lg font-semibold text-gray-900">Error</h3>
        </div>
        <p className="text-sm text-gray-600 mb-6">{message}</p>
        <div className="flex space-x-3">
          {onRetry && (
            <Button onClick={onRetry} className="flex-1">
              <RefreshCw className="h-4 w-4 mr-2" />
              Try Again
            </Button>
          )}
          {onClose && (
            <Button variant="outline" onClick={onClose} className="flex-1">
              Close
            </Button>
          )}
        </div>
      </motion.div>
    </motion.div>
  );
}
