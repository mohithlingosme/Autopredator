'use client';

import { Form, Formik, FormikHelpers } from 'formik';
import * as yup from 'yup';
import { toast, Toaster } from 'react-hot-toast';

export interface JournalFormValues {
  title: string;
  content: string;
  predictionType: string;
  confidence: number;
}

interface JournalFormProps {
  onSubmit?: (values: JournalFormValues) => Promise<void> | void;
  initialValues?: JournalFormValues;
}

const predictionTypes = ['maintenance', 'model-update', 'inspection'];

const JournalFormSchema = yup.object({
  title: yup.string().trim().required('Title is required'),
  content: yup.string().trim().required('Notes cannot be empty'),
  predictionType: yup
    .string()
    .oneOf(predictionTypes, 'Select a valid prediction type')
    .required('Prediction type is required'),
  confidence: yup
    .number()
    .typeError('Provide a confidence value')
    .min(0, 'Confidence must be at least 0')
    .max(1, 'Confidence cannot exceed 1')
    .required('Confidence score is required')
});

const defaultValues: JournalFormValues = {
  title: '',
  content: '',
  predictionType: '',
  confidence: 0.5
};

export default function JournalForm({ onSubmit, initialValues }: JournalFormProps) {
  const formValues = initialValues ?? defaultValues;

  const handleSubmit = async (
    values: JournalFormValues,
    helpers: FormikHelpers<JournalFormValues>
  ) => {
    helpers.setSubmitting(true);
    try {
      await onSubmit?.(values);
      toast.success('Entry saved successfully');
      helpers.resetForm();
    } catch (error) {
      toast.error('Unable to save entry right now');
    } finally {
      helpers.setSubmitting(false);
    }
  };

  return (
    <div className="card bg-white p-6 space-y-6">
      <Toaster position="top-right" toastOptions={{ duration: 2500 }} />
      <h2 className="text-xl font-semibold text-charcoal">Journal Entry</h2>
      <Formik initialValues={formValues} validationSchema={JournalFormSchema} onSubmit={handleSubmit}>
        {({ values, handleChange, handleBlur, errors, touched, isSubmitting }) => (
          <Form className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-600" htmlFor="title">
                Title
              </label>
              <input
                id="title"
                name="title"
                value={values.title}
                onChange={handleChange}
                onBlur={handleBlur}
                className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-blue"
                placeholder="AI prediction recap"
              />
              {touched.title && errors.title && (
                <p className="mt-1 text-xs text-red-600">{errors.title}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-600" htmlFor="content">
                Notes
              </label>
              <textarea
                id="content"
                name="content"
                value={values.content}
                onChange={handleChange}
                onBlur={handleBlur}
                rows={4}
                className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-blue"
                placeholder="Summarize context, data, and insights."
              />
              {touched.content && errors.content && (
                <p className="mt-1 text-xs text-red-600">{errors.content}</p>
              )}
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <label className="block text-sm font-semibold text-gray-600" htmlFor="predictionType">
                  Prediction type
                </label>
                <select
                  id="predictionType"
                  name="predictionType"
                  value={values.predictionType}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-blue"
                >
                  <option value="">Select prediction type</option>
                  {predictionTypes.map(type => (
                    <option key={type} value={type}>
                      {type.replace('-', ' ')}
                    </option>
                  ))}
                </select>
                {touched.predictionType && errors.predictionType && (
                  <p className="mt-1 text-xs text-red-600">{errors.predictionType}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-600" htmlFor="confidence">
                  Confidence (0-1)
                </label>
                <input
                  id="confidence"
                  name="confidence"
                  value={values.confidence}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  type="number"
                  step={0.01}
                  min={0}
                  max={1}
                  className="mt-1 w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-blue"
                />
                {touched.confidence && errors.confidence && (
                  <p className="mt-1 text-xs text-red-600">{errors.confidence}</p>
                )}
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="btn-primary w-full text-center font-semibold"
            >
              {isSubmitting ? 'Saving…' : 'Save entry'}
            </button>
          </Form>
        )}
      </Formik>
    </div>
  );
}
