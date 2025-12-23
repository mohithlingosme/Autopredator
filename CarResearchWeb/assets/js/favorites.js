document.addEventListener('DOMContentLoaded', function() {
    function updateFavoriteButton(btn, isFavorite) {
        btn.textContent = isFavorite ? 'Unfavorite' : 'Favorite';
        btn.classList.toggle('btn-danger', isFavorite);
        btn.classList.toggle('btn-outline', !isFavorite);
    }

    function checkFavoriteStatus(variantId, btn) {
        fetch(`api/favorites.php?action=check&variant_id=${variantId}`)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateFavoriteButton(btn, data.is_favorite);
                }
            })
            .catch(error => console.error('Error checking favorite status:', error));
    }

    function toggleFavorite(variantId, btn) {
        const isCurrentlyFavorite = btn.textContent === 'Unfavorite';
        const action = isCurrentlyFavorite ? 'remove' : 'add';

        fetch(`api/favorites.php?action=${action}&variant_id=${variantId}`, {
            method: 'POST'
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateFavoriteButton(btn, !isCurrentlyFavorite);
                } else {
                    alert('Error updating favorite: ' + (data.message || 'Unknown error'));
                }
            })
            .catch(error => {
                console.error('Error toggling favorite:', error);
                alert('Error updating favorite');
            });
    }

    // Initialize buttons
    document.querySelectorAll('[data-favorite-toggle]').forEach(btn => {
        const variantId = btn.getAttribute('data-favorite-toggle');
        checkFavoriteStatus(variantId, btn);

        btn.addEventListener('click', function() {
            toggleFavorite(variantId, this);
        });
    });
});
