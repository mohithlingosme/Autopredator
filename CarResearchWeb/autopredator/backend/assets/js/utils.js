/* ============================================================ */
/* UTILITIES - SHARED FUNCTIONS FOR THE APPLICATION */
/* ============================================================ */

const Utils = {
    safeLocalStorage: function() {
        try {
            const test = '__localStorage_test__';
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            return localStorage;
        } catch (e) {
            return null;
        }
    },

    showToast: function(message, duration = 3000) {
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        document.body.appendChild(toast);

        setTimeout(() => toast.classList.add('show'), 10);
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => document.body.removeChild(toast), 300);
        }, duration);
    },

    trackEvent: function(event, data = {}) {
        // In production, send to analytics service
        console.log('Analytics:', event, data);
        // Example: gtag('event', event, data);
    },

    debounce: function(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    formatCurrency: function(amount, currency = 'INR') {
        return new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: currency,
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    },

    formatNumber: function(num) {
        return new Intl.NumberFormat('en-IN').format(num);
    },

    truncateText: function(text, maxLength) {
        if (text.length <= maxLength) return text;
        return text.substring(0, maxLength) + '...';
    },

    getUrlParams: function() {
        const params = {};
        const urlParams = new URLSearchParams(window.location.search);
        for (const [key, value] of urlParams) {
            params[key] = value;
        }
        return params;
    },

    updateUrlParams: function(params) {
        const url = new URL(window.location);
        Object.keys(params).forEach(key => {
            if (params[key] === null || params[key] === undefined) {
                url.searchParams.delete(key);
            } else {
                url.searchParams.set(key, params[key]);
            }
        });
        window.history.replaceState(null, '', url);
    },

    copyToClipboard: function(text) {
        if (navigator.clipboard && window.isSecureContext) {
            return navigator.clipboard.writeText(text);
        } else {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            return new Promise((resolve, reject) => {
                if (document.execCommand('copy')) {
                    resolve();
                } else {
                    reject(new Error('Copy failed'));
                }
                document.body.removeChild(textArea);
            });
        }
    },

    isMobile: function() {
        return window.innerWidth < 768;
    },

    isTouchDevice: function() {
        return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    },

    scrollToTop: function(smooth = true) {
        if (smooth && 'scrollBehavior' in document.documentElement.style) {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            window.scrollTo(0, 0);
        }
    },

    loadScript: function(src) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = src;
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    },

    loadCSS: function(href) {
        return new Promise((resolve, reject) => {
            const link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = href;
            link.onload = resolve;
            link.onerror = reject;
            document.head.appendChild(link);
        });
    },

    getCookie: function(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    },

    setCookie: function(name, value, days = 30) {
        const expires = new Date();
        expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
        document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`;
    },

    deleteCookie: function(name) {
        document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
    },

    validateEmail: function(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },

    validatePhone: function(phone) {
        const re = /^[6-9]\d{9}$/;
        return re.test(phone.replace(/\s+/g, ''));
    },

    escapeHtml: function(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },

    unescapeHtml: function(html) {
        const div = document.createElement('div');
        div.innerHTML = html;
        return div.textContent || div.innerText || '';
    },

    generateId: function(prefix = 'id') {
        return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    },

    deepClone: function(obj) {
        return JSON.parse(JSON.stringify(obj));
    },

    mergeObjects: function(target, source) {
        return Object.assign({}, target, source);
    },

    isEmpty: function(obj) {
        if (obj == null) return true;
        if (Array.isArray(obj) || typeof obj === 'string') return obj.length === 0;
        if (typeof obj === 'object') return Object.keys(obj).length === 0;
        return false;
    },

    capitalize: function(str) {
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    },

    camelCase: function(str) {
        return str.replace(/(?:^\w|[A-Z]|\b\w)/g, (word, index) => {
            return index === 0 ? word.toLowerCase() : word.toUpperCase();
        }).replace(/\s+/g, '');
    },

    kebabCase: function(str) {
        return str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
    },

    snakeCase: function(str) {
        return str.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase();
    }
};

// Make Utils globally available
window.Utils = Utils;
