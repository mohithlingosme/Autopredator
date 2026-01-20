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

    // Compare list with localStorage - unified with compare.js
    const loadCompare = () => {
        try { return JSON.parse(localStorage.getItem('compare_variants') || '[]'); } catch { return []; }
    };
    const saveCompare = (list) => localStorage.setItem('compare_variants', JSON.stringify(list.slice(0, 4)));

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
            // Update badge
            updateCompareBadge();
        });
    });

    function updateCompareBadge() {
        const count = loadCompare().length;
        const badge = document.querySelector('[data-compare-count]');
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline';
        } else {
            badge.style.display = 'none';
        }
    }

    // Initialize compare badge
    updateCompareBadge();

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
    let suggestions = {};
    if (suggestionsJson?.textContent) {
        try { suggestions = JSON.parse(suggestionsJson.textContent); } catch (e) { suggestions = {}; }
    }

    let selectedIndex = -1;
    let currentSuggestions = [];

    const renderSuggestions = (filtered) => {
        if (!suggestionEl || filtered.length === 0) {
            suggestionEl?.setAttribute('hidden', 'hidden');
            selectedIndex = -1;
            return;
        }
        currentSuggestions = filtered.slice(0, 6);
        suggestionEl.innerHTML = currentSuggestions.map((item, index) =>
            `<button type="button" class="btn btn-ghost suggestion-item ${index === selectedIndex ? 'selected' : ''}" data-suggest="${item}" data-index="${index}">${item}</button>`
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

    const updateSelection = () => {
        suggestionEl.querySelectorAll('.suggestion-item').forEach((btn, index) => {
            btn.classList.toggle('selected', index === selectedIndex);
        });
    };

    const filterSuggestions = (q) => {
        const filtered = [];
        for (const [category, items] of Object.entries(suggestions)) {
            const matching = items.filter(item => item.toLowerCase().includes(q));
            if (matching.length > 0) {
                filtered.push(...matching.slice(0, 2)); // Limit per category
            }
        }
        return filtered;
    };

    searchInput?.addEventListener('input', () => {
        const q = searchInput.value.trim().toLowerCase();
        if (q.length < 2) { suggestionEl?.setAttribute('hidden', 'hidden'); selectedIndex = -1; return; }
        const filtered = filterSuggestions(q);
        renderSuggestions(filtered);
    });

    searchInput?.addEventListener('keydown', (e) => {
        if (!suggestionEl || suggestionEl.hasAttribute('hidden')) return;
        switch (e.key) {
            case 'ArrowDown':
                e.preventDefault();
                selectedIndex = Math.min(selectedIndex + 1, currentSuggestions.length - 1);
                updateSelection();
                break;
            case 'ArrowUp':
                e.preventDefault();
                selectedIndex = Math.max(selectedIndex - 1, -1);
                updateSelection();
                break;
            case 'Enter':
                e.preventDefault();
                if (selectedIndex >= 0 && currentSuggestions[selectedIndex]) {
                    searchInput.value = currentSuggestions[selectedIndex];
                    suggestionEl.setAttribute('hidden', 'hidden');
                    searchInput.form?.submit();
                }
                break;
            case 'Escape':
                e.preventDefault();
                suggestionEl.setAttribute('hidden', 'hidden');
                selectedIndex = -1;
                break;
        }
    });

    document.addEventListener('click', (e) => {
        if (!suggestionEl || !searchInput) return;
        if (!suggestionEl.contains(e.target) && e.target !== searchInput) {
            suggestionEl.setAttribute('hidden', 'hidden');
            selectedIndex = -1;
        }
    });
})();
