import React, { useState, useRef } from 'react';
import { Upload, X, File } from 'lucide-react';
import Button from './Button';

interface FileUploadProps {
  onFileSelect: (files: File[]) => void;
  accept?: string;
  multiple?: boolean;
  maxSize?: number; // in MB
  label?: string;
}

export default function FileUpload({
  onFileSelect,
  accept = '*',
  multiple = false,
  maxSize = 10,
  label = 'Upload files'
}: FileUploadProps) {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (files: FileList | null) => {
    if (!files) return;

    const fileArray = Array.from(files);
    const validFiles = fileArray.filter(file => {
      if (file.size > maxSize * 1024 * 1024) {
        alert(`File ${file.name} is too large. Maximum size is ${maxSize}MB.`);
        return false;
      }
      return true;
    });

    const newFiles = multiple ? [...selectedFiles, ...validFiles] : validFiles;
    setSelectedFiles(newFiles);
    onFileSelect(newFiles);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);
    handleFileSelect(e.dataTransfer.files);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = () => {
    setDragOver(false);
  };

  const removeFile = (index: number) => {
    const newFiles = selectedFiles.filter((_, i) => i !== index);
    setSelectedFiles(newFiles);
    onFileSelect(newFiles);
  };

  return (
    <div className="space-y-4">
      <div
        className={`border-2 border-dashed rounded-xl p-6 text-center transition-colors ${
          dragOver
            ? 'border-blue bg-blue/5'
            : 'border-gray-300 hover:border-gray-400'
        }`}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
      >
        <Upload className="mx-auto h-12 w-12 text-gray-400" />
        <div className="mt-4">
          <label htmlFor="file-upload" className="cursor-pointer">
            <span className="text-sm font-medium text-blue hover:text-blue/80">
              {label}
            </span>
            <input
              id="file-upload"
              ref={fileInputRef}
              type="file"
              className="sr-only"
              accept={accept}
              multiple={multiple}
              onChange={(e) => handleFileSelect(e.target.files)}
            />
          </label>
          <p className="text-xs text-gray-500 mt-1">
            or drag and drop files here (max {maxSize}MB each)
          </p>
        </div>
      </div>

      {selectedFiles.length > 0 && (
        <div className="space-y-2">
          <h4 className="text-sm font-medium text-gray-700">Selected files:</h4>
          {selectedFiles.map((file, index) => (
            <div
              key={index}
              className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div className="flex items-center space-x-3">
                <File className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm font-medium text-gray-900">{file.name}</p>
                  <p className="text-xs text-gray-500">
                    {(file.size / 1024 / 1024).toFixed(2)} MB
                  </p>
                </div>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => removeFile(index)}
                className="p-1"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
