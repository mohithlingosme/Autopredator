(function() {
    'use strict';

    const MAX_COMPARE = 4;
    const STORAGE_KEY = 'compare_variants';

    function getCompareVariants() {
        const storage = Utils.safeLocalStorage();
        if (!storage) return [];
        try {
            const stored = storage.getItem(STORAGE_KEY);
            return stored ? JSON.parse(stored) : [];
        } catch (e) {
            return [];
        }
    }

    function setCompareVariants(variants) {
        const storage = Utils.safeLocalStorage();
        if (!storage) return;
        try {
            storage.setItem(STORAGE_KEY, JSON.stringify(variants));
        } catch (e) {
            console.error('Failed to save compare variants:', e);
        }
    }

    function addVariant(variantKey) {
        const variants = getCompareVariants();
        if (variants.length >= MAX_COMPARE) {
            Utils.showToast(`You can compare up to ${MAX_COMPARE} variants. Please remove one first.`);
            return false;
        }
        if (!variants.includes(variantKey)) {
            variants.push(variantKey);
            setCompareVariants(variants);
            updateCompareUI();
            updateUrl();
        }
        return true;
    }

    function removeVariant(variantKey) {
        const variants = getCompareVariants();
        const filtered = variants.filter(v => v !== variantKey);
        setCompareVariants(filtered);
        updateCompareUI();
        updateUrl();
    }

    function clearAllVariants() {
        setCompareVariants([]);
        updateCompareUI();
        updateUrl();
        window.location.href = 'compare.php';
    }

    function isVariantInCompare(variantKey) {
        const variants = getCompareVariants();
        return variants.includes(variantKey);
    }

    function getCompareUrl() {
        const variants = getCompareVariants();
        if (variants.length === 0) {
            return 'compare.php';
        }
        return 'compare.php?v=' + encodeURIComponent(variants.join(','));
    }

    function updateUrl() {
        const url = getCompareUrl();
        history.replaceState(null, '', url);
        updateShareUrl();
    }

    function updateShareUrl() {
        const shareBtn = document.getElementById('share-compare-link');
        if (shareBtn) {
            shareBtn.setAttribute('data-share-url', window.location.href);
        }
    }

    function updateCompareUI() {
        const variants = getCompareVariants();
        const bar = document.getElementById('compare-sticky-bar');
        const countEl = document.getElementById('compare-count');
        const chipsEl = document.getElementById('compare-bar-chips');

        if (variants.length > 0 && bar) {
            bar.style.display = 'block';
            if (countEl) countEl.textContent = variants.length;
            if (chipsEl) {
                chipsEl.innerHTML = variants.map(variant => `<span class="chip">${variant}<button onclick="CompareManager.remove('${variant}')">&times;</button></span>`).join('');
            }
        } else if (bar) {
            bar.style.display = 'none';
        }

        updateCompareLinks();
        updateCompareBadge();
        recomputeBestValues();
    }

    function recomputeBestValues() {
        const toggle = document.getElementById('best-value-toggle');
        if (!toggle || !toggle.checked) return;

        const rows = document.querySelectorAll('.compare-table tbody tr');
        rows.forEach(row => {
            const attr = row.getAttribute('data-attr');
            if (!attr) return;

            const cells = Array.from(row.querySelectorAll('td'));
            const values = cells.map(cell => {
                const text = cell.textContent.trim();
                return text === '—' ? null : parseFloat(text.replace(/[^\d.-]/g, ''));
            });

            // Determine best value based on attribute
            let bestIndex = -1;
            if (attr === 'price') {
                // Lower price is better
                const minVal = Math.min(...values.filter(v => v !== null));
                bestIndex = values.indexOf(minVal);
            } else if (['mileage_city_kmpl', 'mileage_highway_kmpl'].includes(attr)) {
                // Higher mileage is better
                const maxVal = Math.max(...values.filter(v => v !== null));
                bestIndex = values.indexOf(maxVal);
            } else {
                // Higher is better for others
                const maxVal = Math.max(...values.filter(v => v !== null));
                bestIndex = values.indexOf(maxVal);
            }

            cells.forEach((cell, index) => {
                cell.classList.toggle('best-value', index === bestIndex);
            });
        });
    }

    function initInlineSearch() {
        const input = document.getElementById('inline-search');
        const suggestions = document.getElementById('inline-search-suggestions');
        if (!input || !suggestions) return;

        let debounceTimer;
        input.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                const query = this.value.trim();
                if (query.length < 2) {
                    suggestions.hidden = true;
                    return;
                }

                // Fetch suggestions (simplified, assuming API endpoint exists)
                fetch(`api/autocomplete.php?q=${encodeURIComponent(query)}`)
                    .then(r => r.json())
                    .then(data => {
                        suggestions.innerHTML = data.map(item => `<a href="#" data-variant="${item.slug}">${item.name}</a>`).join('');
                        suggestions.hidden = false;
                    })
                    .catch(() => {
                        suggestions.hidden = true;
                    });
            }, 300);
        });

        suggestions.addEventListener('click', function(e) {
            e.preventDefault();
            const link = e.target.closest('a');
            if (link) {
                const variant = link.getAttribute('data-variant');
                if (variant && addVariant(variant)) {
                    input.value = '';
                    suggestions.hidden = true;
                }
            }
        });
    }

    // Attach to window for global access
    window.CompareManager = {
        add: addVariant,
        remove: removeVariant,
        clearAll: clearAllVariants,
        has: isVariantInCompare,
        getUrl: getCompareUrl,
        getVariants: getCompareVariants
    };

    // Handle "Add to Compare" buttons
    document.addEventListener('click', function(e) {
        const btn = e.target.closest('[data-compare-add]');
        if (!btn) return;

        e.preventDefault();
        const variantKey = btn.getAttribute('data-compare-add');
        const label = btn.getAttribute('data-compare-label') || variantKey;

        if (addVariant(variantKey)) {
            btn.textContent = 'Added to Compare';
            btn.classList.add('btn-success');
            setTimeout(() => {
                btn.textContent = 'Add to Compare';
                btn.classList.remove('btn-success');
            }, 2000);
        }
    });

    // Handle remove buttons
    document.addEventListener('click', function(e) {
        const btn = e.target.closest('[data-remove-key]');
        if (btn) {
            e.preventDefault();
            const key = btn.getAttribute('data-remove-key');
            removeVariant(key);
        }
    });

    // Update compare links
    function updateCompareLinks() {
        const variants = getCompareVariants();
        const compareLinks = document.querySelectorAll('[href*="compare.php"]');
        compareLinks.forEach(link => {
            if (variants.length > 0) {
                link.href = getCompareUrl();
            }
        });
    }

    // Best value toggle
    document.addEventListener('change', function(e) {
        if (e.target.id === 'best-value-toggle') {
            recomputeBestValues();
        }
    });

    // Initialize
    document.addEventListener('DOMContentLoaded', function() {
        // Restore from URL if present
        const urlParams = new URLSearchParams(window.location.search);
        const ids = urlParams.get('v') || urlParams.get('ids');
        if (ids) {
            const variants = ids.split(',').map(v => v.trim()).filter(v => v);
            setCompareVariants(variants);
        }

        updateCompareUI();
        initInlineSearch();
    });

    // Listen for storage changes (in case of multi-tab)
    window.addEventListener('storage', function(e) {
        if (e.key === STORAGE_KEY) {
            updateCompareUI();
        }
    });
})();
