# UI TODOs (in progress)

Areas that have been scaffolded are marked as ✅; remaining work is noted with ⚠️ where appropriate.

## 1. Project Setup
- ✅ Installed libraries (`react-router-dom`, `react-query`, `formik`, `yup`, `lucide-react`, `chart.js`, `react-hot-toast`).
- ✅ Journal zone layout (sidebar + top nav) with `/journal`, `/journal/[id]`, `/journal/new` routes and placeholder content.

## 2. UI Components
- ✅ General layout components implemented (`JournalSidebar`, `JournalTopNav`, journal layout wrapper).
- ✅ Journal dashboard/graph/entry components with detailed UI (cards, charts, activity graph).
- ✅ Detail view helper bars, timeline, and entry context designed.
- ✅ Entry utilities (`FileUpload`, `ActionCheckboxGroup`) and filters (`DateRangePicker`, `ModelVersionFilter`) implemented.

## 3. UI / UX Design System
- ✅ `tailwind.config.js` updated with custom palette, spacing, and typography settings.
- ✅ Reusable primitives (`Button`, `Card`, `Modal`, `Toast`, `Tooltip`) and design tokens defined.

## 4. State Management & API
- ⚠️ REST API endpoints outlined; integrations still depend on actual backend wiring.
- ✅ Axios wrapper + `useJournalData()` hook for list/detail fetching with React Query caching implemented.
- ✅ Global loading/error overlay components implemented.

## 5. Validation & Form Handling
- ✅ `JournalForm` with Formik/Yup validation and toast feedback is in place.
- ✅ Additional supporting controls (file upload, action checkboxes) with Formik bindings implemented.

## 6. Accessibility (a11y)
- ✅ Basic labels/focus states exist in the form + nav; keyboard-friendly structure is maintained.
- ✅ Additional ARIA annotations (modals/alerts) and contrast audit added per component.

## 7. Responsive Design
- ✅ Mobile-first layout; sidebar hidden below `lg`, top nav sticky. (Charts will also need responsive wrappers.)
- ✅ Drawer-trigger for sidebar and responsive Chart.js containers implemented.

## 8. Animations & Transitions
- ✅ Framer Motion wrappers for page transitions, skeleton states, and animated overlays implemented.
- ✅ Hover motion added to shared cards/buttons.

## 9. Charts & Data Visualization
- ✅ Chart components with real data and tooltip interactions (Chart.js) implemented.

## 10. File & Media Handling
- ✅ File upload preview and validation implemented.
- ⚠️ Backend storage integration remains open.

## 11. Notifications & Feedback
- ✅ Toast success/error handled by `react-hot-toast`.
- ⚠️ Modal confirmation, alert banners, and global notification center should be built when APIs/status flows are ready.
