<?php
// Admin Brochure Extraction Cockpit
include_once __DIR__ . '/../../includes/header.php';
?>

<main class="min-h-screen bg-gray-50 px-6 py-10">
  <div class="mx-auto max-w-6xl">
    <div class="mb-8">
      <p class="text-sm font-semibold uppercase tracking-wide text-indigo-500">PDF Intelligence</p>
      <h1 class="text-3xl font-bold text-gray-900">Brochure Extraction Cockpit</h1>
      <p class="mt-2 text-sm text-gray-600">Drop a brochure PDF and let the AI pre-fill variant specs. Review on the right, then save.</p>
    </div>

    <div class="grid gap-8 lg:grid-cols-2">
      <!-- Upload Column -->
      <section class="rounded-2xl border border-dashed border-gray-300 bg-white p-8 shadow-sm">
        <div id="dropzone"
          class="flex cursor-pointer flex-col items-center justify-center gap-4 rounded-xl border-2 border-dashed border-indigo-200 bg-indigo-50/50 p-10 text-center transition hover:border-indigo-400 hover:bg-indigo-50">
          <div class="flex h-16 w-16 items-center justify-center rounded-full bg-indigo-100 text-indigo-600">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M3 15l6 6m0 0l6-6m-6 6V3" />
            </svg>
          </div>
          <div>
            <p class="text-lg font-semibold text-gray-800">Drag &amp; drop brochure PDF</p>
            <p class="text-sm text-gray-600">or click to browse from your computer</p>
          </div>
          <input id="fileInput" type="file" accept="application/pdf" class="hidden" />
          <p class="text-xs text-gray-500">Max 25MB • PDF only</p>
        </div>

        <div id="uploadStatus" class="mt-6 hidden items-center gap-3 rounded-lg bg-indigo-50 px-4 py-3 text-sm text-indigo-800">
          <svg class="h-5 w-5 animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
          </svg>
          <span>Extracting specs from brochure…</span>
        </div>

        <div id="uploadError" class="mt-4 hidden rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700"></div>
      </section>

      <!-- Staging Area -->
      <section class="rounded-2xl border border-gray-200 bg-white p-8 shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">Staging Area</p>
            <h2 class="text-2xl font-bold text-gray-900">Extracted Specs</h2>
          </div>
          <button id="saveBtn"
            class="inline-flex items-center gap-2 rounded-lg bg-emerald-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-emerald-700 transition">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5 13l4 4L19 7" />
            </svg>
            Save to Database
          </button>
        </div>

        <form class="mt-6 space-y-4" id="stagingForm">
          <div class="grid gap-4 sm:grid-cols-2">
            <label class="block text-sm font-medium text-gray-700">
              Model Name
              <input id="model_name" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="e.g., Nexon EV" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Variant Name
              <input id="variant_name" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="e.g., Fearless+" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Engine (cc)
              <input id="engine_cc" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="1497" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Max Power
              <input id="max_power" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="150 PS" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Max Torque
              <input id="max_torque" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="260 Nm" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Mileage (ARAI)
              <input id="mileage_arai" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="18.5 km/l" />
            </label>
            <label class="block text-sm font-medium text-gray-700">
              Transmission
              <input id="transmission" type="text" class="mt-1 w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" placeholder="6MT / e-AT" />
            </label>
          </div>
        </form>
      </section>
    </div>
  </div>
</main>

<script>
  (function () {
    const dropzone = document.getElementById('dropzone');
    const fileInput = document.getElementById('fileInput');
    const uploadStatus = document.getElementById('uploadStatus');
    const uploadError = document.getElementById('uploadError');
    const saveBtn = document.getElementById('saveBtn');
    const apiUrl = '/api/admin/extract-proxy.php';

    const fields = ['model_name', 'variant_name', 'engine_cc', 'max_power', 'max_torque', 'mileage_arai', 'transmission'];

    const setLoading = (isLoading) => {
      uploadStatus.classList.toggle('hidden', !isLoading);
      uploadError.classList.add('hidden');
      dropzone.classList.toggle('pointer-events-none', isLoading);
      saveBtn.disabled = isLoading;
      saveBtn.classList.toggle('opacity-60', isLoading);
    };

    const fillFields = (data) => {
      fields.forEach((key) => {
        const el = document.getElementById(key);
        if (el && data[key] !== undefined && data[key] !== null) {
          el.value = data[key];
        }
      });
    };

    const showError = (message) => {
      uploadError.textContent = message;
      uploadError.classList.remove('hidden');
    };

    const uploadFile = (file) => {
      if (!file) return;
      setLoading(true);

      const formData = new FormData();
      formData.append('file', file);

      fetch(apiUrl, {
        method: 'POST',
        body: formData,
      })
        .then(async (res) => {
          const text = await res.text();
          try {
            const json = JSON.parse(text);
            if (!res.ok) {
              throw new Error(json?.error || 'Extraction failed');
            }
            fillFields(json);
          } catch (err) {
            console.error(err);
            showError(err.message || 'Unable to parse response.');
          }
        })
        .catch((err) => {
          console.error(err);
          showError('Network error or extraction service unavailable.');
        })
        .finally(() => {
          setLoading(false);
        });
    };

    dropzone.addEventListener('click', () => fileInput.click());

    dropzone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropzone.classList.add('border-indigo-500', 'bg-indigo-50');
    });

    dropzone.addEventListener('dragleave', () => {
      dropzone.classList.remove('border-indigo-500', 'bg-indigo-50');
    });

    dropzone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropzone.classList.remove('border-indigo-500', 'bg-indigo-50');
      const file = e.dataTransfer.files[0];
      uploadFile(file);
    });

    fileInput.addEventListener('change', (e) => {
      const file = e.target.files[0];
      uploadFile(file);
    });

    saveBtn.addEventListener('click', (e) => {
      e.preventDefault();
      const payload = {};
      fields.forEach((key) => {
        const el = document.getElementById(key);
        payload[key] = el ? el.value : '';
      });
      console.log('Save to Database payload', payload);
      alert('Data staged. Implement persistence to save to DB.');
    });
  })();
</script>

<?php include_once __DIR__ . '/../../includes/footer.php'; ?>
