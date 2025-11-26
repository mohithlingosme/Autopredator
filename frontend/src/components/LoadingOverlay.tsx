import React from 'react';
import { motion } from 'framer-motion';

interface LoadingOverlayProps {
  isVisible: boolean;
  message?: string;
}

export default function LoadingOverlay({ isVisible, message = 'Loading...' }: LoadingOverlayProps) {
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
        className="bg-white rounded-lg p-6 shadow-xl flex flex-col items-center"
      >
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-4"></div>
        <p className="text-sm text-gray-600">{message}</p>
      </motion.div>
    </motion.div>
  );
}
