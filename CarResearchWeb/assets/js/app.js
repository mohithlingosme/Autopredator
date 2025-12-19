(() => {
    const navToggle = document.querySelector('[data-nav-toggle]');
    const navLinks = document.querySelector('[data-nav-links]');
    navToggle?.addEventListener('click', () => {
        navLinks?.classList.toggle('is-open');
    });

    // Filter drawer
    const filterPanel = document.querySelector('[data-filter-panel]');
    document.querySelectorAll('[data-filter-toggle]').forEach(btn => {
        btn.addEventListener('click', () => filterPanel?.classList.add('is-open'));
    });
    document.querySelectorAll('[data-filter-close]').forEach(btn => {
        btn.addEventListener('click', () => filterPanel?.classList.remove('is-open'));
    });

    // Compare list with localStorage
    const STORAGE_KEY = 'autopredator-compare';
    const loadCompare = () => {
        try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); } catch { return []; }
    };
    const saveCompare = (list) => localStorage.setItem(STORAGE_KEY, JSON.stringify(list.slice(0, 4)));

    document.querySelectorAll('[data-compare-add]').forEach(btn => {
        btn.addEventListener('click', () => {
            const model = btn.getAttribute('data-compare-add');
            const label = btn.getAttribute('data-compare-label') || model;
            if (!model) return;
            const list = loadCompare();
            if (!list.includes(model)) list.push(model);
            saveCompare(list);
            btn.textContent = 'Added';
            btn.classList.add('btn-primary');
            btn.setAttribute('aria-label', `Added ${label} to compare`);
        });
    });

    // Pagination jump
    document.querySelectorAll('[data-pagination-jump]').forEach(input => {
        input.addEventListener('change', () => {
            const base = input.getAttribute('data-pagination-base') || '';
            const page = Math.max(1, parseInt(input.value || '1', 10));
            window.location.href = `${base}&page=${page}`;
        });
    });

    // Search suggestions from embedded JSON
    const suggestionEl = document.querySelector('[data-search-suggestions]');
    const searchInput = document.querySelector('[data-search-input]');
    const suggestionsJson = document.getElementById('search-suggestions');
    let suggestions = [];
    if (suggestionsJson?.textContent) {
        try { suggestions = JSON.parse(suggestionsJson.textContent); } catch (e) { suggestions = []; }
    }

    const renderSuggestions = (list) => {
        if (!suggestionEl || list.length === 0) {
            suggestionEl?.setAttribute('hidden', 'hidden');
            return;
        }
        suggestionEl.innerHTML = list.slice(0, 6).map(item =>
            `<button type="button" class="btn btn-ghost suggestion-item" data-suggest="${item}">${item}</button>`
        ).join('');
        suggestionEl.removeAttribute('hidden');
        suggestionEl.querySelectorAll('[data-suggest]').forEach(btn => {
            btn.addEventListener('click', () => {
                searchInput.value = btn.getAttribute('data-suggest');
                suggestionEl.setAttribute('hidden', 'hidden');
                searchInput.form?.submit();
            });
        });
    };

    searchInput?.addEventListener('input', () => {
        const q = searchInput.value.trim().toLowerCase();
        if (q.length < 2) { suggestionEl?.setAttribute('hidden', 'hidden'); return; }
        const filtered = suggestions.filter(item => item.toLowerCase().includes(q));
        renderSuggestions(filtered);
    });
    document.addEventListener('click', (e) => {
        if (!suggestionEl || !searchInput) return;
        if (!suggestionEl.contains(e.target) && e.target !== searchInput) {
            suggestionEl.setAttribute('hidden', 'hidden');
        }
    });
})();
