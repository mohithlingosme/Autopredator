(function() {
    'use strict';

    const MAX_COMPARE = 4;
    const STORAGE_KEY = 'compare_variants';

    function getCompareVariants() {
        try {
            const stored = localStorage.getItem(STORAGE_KEY);
            return stored ? JSON.parse(stored) : [];
        } catch (e) {
            return [];
        }
    }

    function setCompareVariants(variants) {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(variants));
        } catch (e) {
            console.error('Failed to save compare variants:', e);
        }
    }

    function addVariant(variantKey) {
        const variants = getCompareVariants();
        if (variants.length >= MAX_COMPARE) {
            alert(`You can compare up to ${MAX_COMPARE} variants. Please remove one first.`);
            return false;
        }
        if (!variants.includes(variantKey)) {
            variants.push(variantKey);
            setCompareVariants(variants);
        }
        return true;
    }

    function removeVariant(variantKey) {
        const variants = getCompareVariants();
        const filtered = variants.filter(v => v !== variantKey);
        setCompareVariants(filtered);
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
        return 'compare.php?ids=' + encodeURIComponent(variants.join(','));
    }

    // Attach to window for global access
    window.CompareManager = {
        add: addVariant,
        remove: removeVariant,
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

    // Initial update
    updateCompareLinks();
    updateCompareBadge();

    // Listen for storage changes (in case of multi-tab)
    window.addEventListener('storage', function(e) {
        if (e.key === STORAGE_KEY) {
            updateCompareLinks();
            updateCompareBadge();
        }
    });
})();
