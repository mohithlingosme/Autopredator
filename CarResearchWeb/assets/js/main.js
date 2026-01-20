/* ============================================================ */
/* AUTOPREDATOR - MAIN JS (RED/BLACK THEME) */
/* ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
    initNavbar();
    initTabs();
    initFilterToggles();
    initFavorites();
    initCompareManager();
});

/* NAVBAR */
function initNavbar() {
    const toggle = document.querySelector('.nav-toggle');
    const header = document.querySelector('.site-header');
    if (!toggle || !header) return;

    toggle.addEventListener('click', () => {
        header.classList.toggle('nav-open');
    });
}

/* TABS */
function initTabs() {
    document.querySelectorAll('.tab-button').forEach((btn) => {
        btn.addEventListener('click', () => {
            const target = btn.dataset.tab;
            if (!target) return;
            document.querySelectorAll('.tab-button').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
            btn.classList.add('active');
            const panel = document.getElementById(target);
            if (panel) panel.classList.add('active');
        });
    });
}

/* FILTER PANEL (mobile) */
function initFilterToggles() {
    const filterToggle = document.querySelector('[data-filter-toggle]');
    const filterPanel = document.querySelector('[data-filter-panel]');
    if (filterToggle && filterPanel) {
        filterToggle.addEventListener('click', () => {
            filterPanel.classList.toggle('open');
        });
    }
}

/* FAVORITES (session-based API) */
function initFavorites() {
    document.querySelectorAll('.fav-button, .fav-btn').forEach((btn) => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const variantId = btn.dataset.variantId;
            const isFavorite = btn.dataset.isFavorite === '1';
            const action = isFavorite ? 'remove' : 'add';

            fetch(`api/favorites.php?action=${action}&variant_id=${variantId}`)
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        btn.dataset.isFavorite = action === 'add' ? '1' : '0';
                        btn.textContent = action === 'add' ? '♥ Remove' : '♡ Save';
                    }
                })
                .catch(() => {});
        });
    });
}

/* COMPARE MANAGER (localStorage) */
const CompareManager = (() => {
    const key = 'compareList';
    let list = [];

    function load() {
        try {
            const raw = localStorage.getItem(key);
            list = raw ? JSON.parse(raw) : [];
        } catch (e) {
            list = [];
        }
    }

    function save() {
        localStorage.setItem(key, JSON.stringify(list));
    }

    function add(id) {
        if (!list.includes(id) && list.length < 4) {
            list.push(id);
            save();
        }
    }

    function remove(id) {
        list = list.filter(v => v !== id);
        save();
    }

    function clear() {
        list = [];
        save();
    }

    function getList() {
        return list;
    }

    function isSelected(id) {
        return list.includes(id);
    }

    load();
    return { add, remove, clear, getList, isSelected };
})();

function initCompareButtons() {
    document.querySelectorAll('.btn-compare-toggle').forEach((btn) => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const id = parseInt(btn.dataset.variantId || '0', 10);
            if (!id) return;
            if (CompareManager.isSelected(id)) {
                CompareManager.remove(id);
            } else {
                CompareManager.add(id);
            }
            updateCompareButtons();
            updateCompareBar();
        });
    });
}

function updateCompareButtons() {
    document.querySelectorAll('.btn-compare-toggle').forEach((btn) => {
        const id = parseInt(btn.dataset.variantId || '0', 10);
        if (!id) return;
        const selected = CompareManager.isSelected(id);
        btn.textContent = selected ? 'Remove from Compare' : 'Add to Compare';
        btn.classList.toggle('selected', selected);
    });
}

function updateCompareBar() {
    const bar = document.querySelector('[data-compare-bar]');
    const countEl = document.querySelector('[data-compare-count]');
    const linkEl = document.querySelector('[data-compare-link]');
    if (!bar || !countEl || !linkEl) return;

    const list = CompareManager.getList();
    const hasItems = list.length > 0;
    bar.hidden = !hasItems;
    countEl.textContent = String(list.length);
    linkEl.classList.toggle('disabled', list.length < 2);
    linkEl.setAttribute('href', list.length ? `compare.php?ids=${encodeURIComponent(list.join(','))}` : 'compare.php');
}

function initCompareBar() {
    const clearBtn = document.querySelector('[data-compare-clear]');
    if (clearBtn) {
        clearBtn.addEventListener('click', () => {
            CompareManager.clear();
            updateCompareButtons();
            updateCompareBar();
        });
    }

    const linkEl = document.querySelector('[data-compare-link]');
    if (linkEl) {
        linkEl.addEventListener('click', (e) => {
            const list = CompareManager.getList();
            if (list.length < 2) {
                e.preventDefault();
                alert('Select at least two variants to compare.');
            }
        });
    }
}

function initCompareManager() {
    updateCompareButtons();
    updateCompareBar();
    initCompareButtons();
    initCompareBar();
}

/* Format helpers (optional global) */
function formatPrice(price) {
    if (price >= 10000000) return '₹' + (price / 10000000).toFixed(1) + ' Cr';
    if (price >= 100000) return '₹' + (price / 100000).toFixed(1) + ' L';
    return '₹' + Number(price || 0).toLocaleString('en-IN');
}

window.autopredator = { formatPrice, CompareManager };
