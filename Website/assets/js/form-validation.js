// Client-side validation for contact and login forms
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    initContactValidation();
    initLoginValidation();
  });

  function showErrors(container, errors) {
    if (!container) return;
    container.textContent = '';
    if (!errors.length) {
      container.classList.remove('alert', 'alert-error');
      return;
    }
    container.classList.add('alert', 'alert-error');
    container.textContent = errors.join(' ');
  }

  function markInvalid(inputs) {
    inputs.forEach((input) => input.classList.add('input-error'));
  }

  function clearInvalid(form) {
    const fields = form.querySelectorAll('.input-error');
    fields.forEach((f) => f.classList.remove('input-error'));
  }

  // Contact form validation
  function initContactValidation() {
    const form =
      document.getElementById('contact-form') ||
      document.querySelector('form[action*="contact-submit.php"]');
    if (!form) return;

    const errorsContainer =
      document.getElementById('contact-errors') ||
      form.querySelector('.form-errors') ||
      createErrorContainer(form);

    form.addEventListener('submit', function (e) {
      clearInvalid(form);
      const errors = [];
      const invalidFields = [];

      const name = form.querySelector('#contact-name') || form.querySelector('input[name="name"]');
      const email = form.querySelector('#contact-email') || form.querySelector('input[name="email"]');
      const phone = form.querySelector('#contact-phone') || form.querySelector('input[name="phone"]');
      const company = form.querySelector('#contact-company') || form.querySelector('input[name="company"]');
      const fleet = form.querySelector('#contact-fleet-size') || form.querySelector('[name="fleet_size"]');
      const message = form.querySelector('#contact-message') || form.querySelector('textarea[name="message"]');

      if (!name || name.value.trim().length < 2) {
        errors.push('Name is required (min 2 characters).');
        if (name) invalidFields.push(name);
      }

      if (!email || !isValidEmail(email.value)) {
        errors.push('A valid email is required.');
        if (email) invalidFields.push(email);
      }

      if (phone && phone.value.trim() !== '' && phone.value.trim().length < 7) {
        errors.push('Phone should be at least 7 characters if provided.');
        invalidFields.push(phone);
      }

      if (message && message.value.trim() !== '' && message.value.trim().length < 10) {
        errors.push('Message should be at least 10 characters if provided.');
        invalidFields.push(message);
      }

      if (errors.length) {
        e.preventDefault();
        markInvalid(invalidFields);
        showErrors(errorsContainer, errors);
      } else {
        showErrors(errorsContainer, []);
      }
    });
  }

  // Login form validation
  function initLoginValidation() {
    const form =
      document.getElementById('login-form') ||
      document.querySelector('form[action$="login.php"]');
    if (!form) return;

    const errorsContainer =
      document.getElementById('login-errors') ||
      form.querySelector('.form-errors') ||
      createErrorContainer(form);

    form.addEventListener('submit', function (e) {
      clearInvalid(form);
      const errors = [];
      const invalidFields = [];

      const email = form.querySelector('#login-email') || form.querySelector('input[name="email"]');
      const password =
        form.querySelector('#login-password') || form.querySelector('input[name="password"]');

      if (!email || !isValidEmail(email.value)) {
        errors.push('Enter a valid email.');
        if (email) invalidFields.push(email);
      }

      if (!password || password.value.length < 6) {
        errors.push('Password must be at least 6 characters.');
        if (password) invalidFields.push(password);
      }

      if (errors.length) {
        e.preventDefault();
        markInvalid(invalidFields);
        showErrors(errorsContainer, errors);
      } else {
        showErrors(errorsContainer, []);
      }
    });
  }

  function isValidEmail(value) {
    return /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(String(value).trim());
  }

  function createErrorContainer(form) {
    const div = document.createElement('div');
    div.className = 'form-errors';
    form.appendChild(div);
    return div;
  }
})();
