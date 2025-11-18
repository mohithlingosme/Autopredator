'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import JournalTopNav from '@/components/JournalTopNav';
import JournalForm, { JournalFormValues } from '@/components/JournalForm';
import FileUpload from '@/components/FileUpload';
import ActionCheckboxGroup from '@/components/ActionCheckboxGroup';
import Card from '@/components/Card';
import Button from '@/components/Button';
import { Upload, Settings } from 'lucide-react';

export default function JournalNewEntryPage() {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [selectedActions, setSelectedActions] = useState<string[]>([]);

  const actionOptions = [
    { id: 'analyze', label: 'Analyze data', description: 'Run predictive analysis on uploaded data' },
    { id: 'validate', label: 'Validate inputs', description: 'Check data quality and consistency' },
    { id: 'export', label: 'Export results', description: 'Generate downloadable report' },
    { id: 'notify', label: 'Send notifications', description: 'Alert relevant stakeholders' },
  ];

  const handleFormSubmit = async (values: JournalFormValues) => {
    console.log('Form submitted:', values);
    console.log('Files:', selectedFiles);
    console.log('Actions:', selectedActions);
    // TODO: Integrate with API
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="space-y-6"
    >
      <JournalTopNav
        title="Create new entry"
        breadcrumbs={[
          { label: 'Journal', href: '/journal' },
          { label: 'New entry' }
        ]}
      />

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <JournalForm onSubmit={handleFormSubmit} />
          </Card>

          <Card>
            <div className="flex items-center mb-4">
              <Upload className="h-5 w-5 text-blue mr-2" />
              <h3 className="text-lg font-semibold text-charcoal">Upload Data</h3>
            </div>
            <FileUpload
              onFileSelect={setSelectedFiles}
              accept=".csv,.json,.xlsx,.txt"
              multiple={true}
              maxSize={50}
              label="Choose data files"
            />
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <div className="flex items-center mb-4">
              <Settings className="h-5 w-5 text-blue mr-2" />
              <h3 className="text-lg font-semibold text-charcoal">Actions</h3>
            </div>
            <ActionCheckboxGroup
              options={actionOptions}
              selected={selectedActions}
              onChange={setSelectedActions}
              label="Select actions to perform"
            />
          </Card>

          <Card>
            <h3 className="text-lg font-semibold text-charcoal mb-4">Quick Actions</h3>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start">
                <Upload className="h-4 w-4 mr-2" />
                Import from template
              </Button>
              <Button variant="outline" className="w-full justify-start">
                <Settings className="h-4 w-4 mr-2" />
                Load previous entry
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </motion.div>
  );
}
