document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.querySelector('.nav');

  const setMenuOpen = (open) => {
    if (!toggle || !nav) return;
    nav.classList.toggle('open', open);
    toggle.setAttribute('aria-expanded', String(open));
    toggle.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
  };

  if (toggle && nav) {
    toggle.addEventListener('click', () => {
      setMenuOpen(!nav.classList.contains('open'));
    });

    nav.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => setMenuOpen(false));
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && nav.classList.contains('open')) {
        setMenuOpen(false);
        toggle.focus();
      }
    });
  }

  const currentPage = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav a').forEach((link) => {
    if (link.getAttribute('href') === currentPage) {
      link.classList.add('active');
      link.setAttribute('aria-current', 'page');
    }
  });
});