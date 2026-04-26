document.addEventListener('DOMContentLoaded', function() {
    function updateShortlistBadge() {
        const count = JSON.parse(localStorage.getItem('shortlist_variants') || '[]').length;
        const badge = document.querySelector('[data-shortlist-count]');
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline';
        } else {
            badge.style.display = 'none';
        }
    }

    // Add to shortlist
    document.addEventListener('click', function(e) {
        if (e.target.matches('[data-shortlist-add]')) {
            e.preventDefault();
            const variantId = e.target.getAttribute('data-shortlist-add');
            let shortlist = JSON.parse(localStorage.getItem('shortlist_variants') || '[]');
            if (!shortlist.includes(variantId)) {
                shortlist.push(variantId);
                localStorage.setItem('shortlist_variants', JSON.stringify(shortlist));
                updateShortlistBadge();
                // Dispatch custom event
                window.dispatchEvent(new Event('updateBadges'));
                // Optional: Show feedback
                e.target.textContent = 'Shortlisted';
                e.target.disabled = true;
            }
        }
    });

    // Initialize badge
    updateShortlistBadge();
});
