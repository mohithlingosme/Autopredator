// Core UI interactions for Autopredator (palette handled in CSS only)
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    initSmoothScroll();
    initNavToggle();
    initActiveLinks();
    initContactForm();
    initMiniLeadForms();
    initNewsletterForm();
    initCTATracking();
  });

  // Smooth scroll for in-page anchors
  function initSmoothScroll() {
    const links = Array.from(document.querySelectorAll('a[href^="#"]'));
    links.forEach((link) => {
      const href = link.getAttribute('href');
      if (!href || href === '#') return;
      const target = document.querySelector(href);
      if (!target) return;
      link.addEventListener('click', function (e) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });
  }

  // Mobile nav toggle (expects .nav-toggle and .nav-links/.nav)
  function initNavToggle() {
    const toggle = document.querySelector('.nav-toggle');
    const nav = document.querySelector('.nav-links');
    if (!toggle || !nav) return;

    const closeNav = () => {
      document.body.classList.remove('nav-open');
      toggle.setAttribute('aria-expanded', 'false');
    };

    toggle.addEventListener('click', function () {
      const isOpen = document.body.classList.toggle('nav-open');
      toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });

    nav.addEventListener('click', function (e) {
      if (e.target && e.target.matches('a')) {
        closeNav();
      }
    });
  }

  // Active link highlighting based on section in view
  function initActiveLinks() {
    const sectionIds = [
      '#hero',
      '#solutions',
      '#industries',
      '#how-it-works',
      '#pricing',
      '#resources',
      '#about',
      '#contact',
    ];
    const sections = sectionIds
      .map((id) => document.querySelector(id))
      .filter(Boolean);
    if (!sections.length) return;

    const navLinks = Array.from(
      document.querySelectorAll('.nav a[href^="#"], .nav-links a[href^="#"]')
    );
    if (!navLinks.length) return;

    const setActive = (id) => {
      navLinks.forEach((link) => {
        const href = link.getAttribute('href');
        if (href === id) {
          link.classList.add('is-active');
        } else {
          link.classList.remove('is-active');
        }
      });
    };

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              setActive('#' + entry.target.id);
            }
          });
        },
        { threshold: 0.4 }
      );
      sections.forEach((section) => observer.observe(section));
    } else {
      window.addEventListener('scroll', () => {
        const scrollPos = window.scrollY || document.documentElement.scrollTop;
        sections.forEach((section) => {
          const top = section.offsetTop;
          const height = section.offsetHeight;
          if (scrollPos >= top - height * 0.2 && scrollPos < top + height * 0.8) {
            setActive('#' + section.id);
          }
        });
      });
    }
  }

  function initContactForm() {
    const form = document.querySelector('#contact-form');
    const errorBox = document.querySelector('#contact-errors');
    if (!form) return;

    form.addEventListener('submit', function (e) {
      const name = form.querySelector('#name');
      const email = form.querySelector('#email');
      const message = form.querySelector('#message');
      const errors = [];
      if (name && !name.value.trim()) errors.push('Name is required.');
      if (email && !email.value.trim()) errors.push('Email is required.');
      if (email && email.value && !email.validity.valid) errors.push('Enter a valid email.');
      if (message && !message.value.trim()) errors.push('Message is required.');
      if (errors.length) {
        e.preventDefault();
        if (errorBox) {
          errorBox.innerHTML = errors.map((err) => `<div class="alert alert-error">${err}</div>`).join('');
        }
      }
    });
  }

  function initMiniLeadForms() {
    const forms = Array.from(document.querySelectorAll('[data-mini-lead-form]'));
    if (!forms.length || !window.fetch) return;

    forms.forEach((form) => {
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        const formData = new FormData(form);
        const statusEl = form.querySelector('.form-status');
        statusEl && (statusEl.textContent = 'Submitting...');

        fetch(form.getAttribute('action') || '/api/api-lead-create.php', {
          method: 'POST',
          body: formData,
        })
          .then((res) => res.json())
          .then((data) => {
            if (data.success) {
              statusEl && (statusEl.textContent = data.message || 'Thanks! We will reach out.');
              form.reset();
            } else {
              statusEl && (statusEl.textContent = data.message || 'We could not submit this form.');
            }
          })
          .catch(() => {
            statusEl && (statusEl.textContent = 'Network error. Please try again.');
          });
      });
    });
  }

  function initNewsletterForm() {
    const form = document.querySelector('[data-newsletter-form]');
    if (!form || !window.fetch) return;
    const statusEl = form.querySelector('.form-status');

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      const formData = new FormData(form);
      statusEl && (statusEl.textContent = 'Submitting...');

      fetch(form.getAttribute('action') || '/api/api-newsletter.php', {
        method: 'POST',
        body: formData,
      })
        .then((res) => res.json())
        .then((data) => {
          if (data.success) {
            statusEl && (statusEl.textContent = data.message || 'Thanks! You are on the list.');
            form.reset();
          } else {
            statusEl && (statusEl.textContent = data.message || 'We could not save your email.');
          }
        })
        .catch(() => {
          statusEl && (statusEl.textContent = 'Network error. Please try again.');
        });
    });
  }

  function initCTATracking() {
    const ctas = Array.from(document.querySelectorAll('[data-cta]'));
    if (!ctas.length) return;

    ctas.forEach((cta) => {
      cta.addEventListener('click', () => {
        const label = cta.getAttribute('data-cta') || 'cta';
        if (typeof gtag === 'function') {
          gtag('event', 'cta_click', { event_category: 'engagement', event_label: label });
        } else {
          console.debug('[CTA]', label);
        }
      });
    });
  }
})();
