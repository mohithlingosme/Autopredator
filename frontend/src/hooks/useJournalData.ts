import { useQuery, useMutation, useQueryClient } from 'react-query';
import { journalApi } from '@/lib/api';
import { JournalFormValues } from '@/components/JournalForm';

export interface JournalEntry {
  id: string;
  title: string;
  content: string;
  predictionType: string;
  confidence: number;
  createdAt: string;
  updatedAt: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  files?: string[];
}

// Hook for fetching journal entries list
export function useJournalEntries(params?: {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
}) {
  return useQuery(
    ['journal-entries', params],
    () => journalApi.getEntries(params).then(res => res.data),
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
    }
  );
}

// Hook for fetching single journal entry
export function useJournalEntry(id: string) {
  return useQuery(
    ['journal-entry', id],
    () => journalApi.getEntry(id).then(res => res.data),
    {
      enabled: !!id,
      staleTime: 5 * 60 * 1000,
    }
  );
}

// Hook for creating new journal entry
export function useCreateJournalEntry() {
  const queryClient = useQueryClient();

  return useMutation(
    (data: JournalFormValues & { files?: File[] }) => journalApi.createEntry(data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('journal-entries');
      },
    }
  );
}

// Hook for updating journal entry
export function useUpdateJournalEntry() {
  const queryClient = useQueryClient();

  return useMutation(
    ({ id, data }: { id: string; data: Partial<JournalFormValues> }) =>
      journalApi.updateEntry(id, data),
    {
      onSuccess: (_, { id }) => {
        queryClient.invalidateQueries(['journal-entry', id]);
        queryClient.invalidateQueries('journal-entries');
      },
    }
  );
}

// Hook for deleting journal entry
export function useDeleteJournalEntry() {
  const queryClient = useQueryClient();

  return useMutation(
    (id: string) => journalApi.deleteEntry(id),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('journal-entries');
      },
    }
  );
}

// Hook for uploading files
export function useUploadFiles() {
  return useMutation((files: File[]) => journalApi.uploadFiles(files));
}
