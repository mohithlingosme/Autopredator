/* ============================================================ */
/* TRUST FEATURES - RECENTLY VIEWED, SHARE LINKS, ANALYTICS */
/* ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
    initRecentlyViewed();
    initShareLinks();
    initAnalytics();
});

/* RECENTLY VIEWED */
function initRecentlyViewed() {
    const key = 'recent_variants';
    const maxItems = 10;

    // Add current variant to recently viewed if on variant page
    const urlParams = new URLSearchParams(window.location.search);
    const variantId = urlParams.get('variant_id');
    if (variantId) {
        addToRecentlyViewed(variantId);
    }

    // Display recently viewed on home page
    if (window.location.pathname.endsWith('index.php') || window.location.pathname === '/') {
        displayRecentlyViewed();
    }

    function addToRecentlyViewed(id) {
        const storage = Utils.safeLocalStorage();
        if (!storage) return;

        let list = JSON.parse(storage.getItem(key) || '[]');
        list = list.filter(item => item.slug !== id); // Remove if already exists (dedupe by slug)
        list.unshift({ slug: id, ts: Date.now() }); // Add to front with timestamp
        list = list.slice(0, maxItems); // Limit to max
        storage.setItem(key, JSON.stringify(list));
    }

    function displayRecentlyViewed() {
        const storage = Utils.safeLocalStorage();
        if (!storage) return;

        const list = JSON.parse(storage.getItem(key) || '[]');
        if (list.length === 0) return;

        const container = document.querySelector('[data-recently-viewed]');
        if (!container) return;

        // Fetch variant data from JSON script if available
        const variantMeta = document.querySelector('#variant-meta');
        if (!variantMeta) return;

        const variants = JSON.parse(variantMeta.textContent || '[]');
        const recentVariants = list.slice(0, 4).map(item => variants.find(v => v.slug === item.slug)).filter(Boolean);

        if (recentVariants.length === 0) return;

        container.innerHTML = '<h3>Recently Viewed</h3><div class="grid grid-4">' +
            recentVariants.map(variant => `
                <div class="card">
                    <a href="${variant.url || '#'}">
                        ${variant.imageUrl ? `<img src="${variant.imageUrl}" alt="${variant.name}" style="width:100%; height:auto;">` : ''}
                        <strong>${variant.name}</strong><br>
                        <span class="muted">${variant.priceText || ''}</span>
                    </a>
                </div>
            `).join('') +
            '</div>';
    }
}

/* SHARE LINKS */
function initShareLinks() {
    document.querySelectorAll('[data-share-url]').forEach(btn => {
        btn.addEventListener('click', () => {
            const url = btn.getAttribute('data-share-url') || window.location.href;
            navigator.clipboard.writeText(url).then(() => {
                Utils.showToast('Link copied');
            }).catch(() => {
                Utils.showToast('Failed to copy link');
            });
        });
    });
}

/* ANALYTICS */
function initAnalytics() {
    // Track key events
    function trackEvent(event, data = {}) {
        Utils.trackEvent(event, data);
    }

    // Track compare add
    document.addEventListener('click', e => {
        if (e.target.closest('[data-compare-add]')) {
            const slug = e.target.closest('[data-compare-add]').getAttribute('data-compare-add');
            trackEvent('compare_add', { slug });
        }
    });

    // Track compare remove
    document.addEventListener('click', e => {
        if (e.target.closest('[data-compare-remove]')) {
            const slug = e.target.closest('[data-compare-remove]').getAttribute('data-compare-remove');
            trackEvent('compare_remove', { slug });
        }
    });

    // Track shortlist add
    document.addEventListener('click', e => {
        if (e.target.closest('[data-shortlist-add]')) {
            const slug = e.target.closest('[data-shortlist-add]').getAttribute('data-shortlist-add');
            trackEvent('shortlist_add', { slug });
        }
    });

    // Track search submit
    document.addEventListener('submit', e => {
        if (e.target.matches('form[action*="search"]')) {
            const q = e.target.querySelector('input[name="q"]')?.value;
            const filters = {};
            e.target.querySelectorAll('input[name]:not([name="q"]), select[name]').forEach(el => {
                if (el.value) filters[el.name] = el.value;
            });
            trackEvent('search_submit', { q, filters });
        }
    });

    // Track page views
    trackEvent('page_view', { path: window.location.pathname });
}
