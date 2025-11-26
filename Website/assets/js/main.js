// Core UI interactions for Autopredator (palette handled in CSS only)
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    initSmoothScroll();
    initNavToggle();
    initActiveLinks();
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
})();
