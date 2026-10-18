// AI Tech Horizon - Clean & Non-Blocking Client Script
document.addEventListener('DOMContentLoaded', () => {
    // 1. Smooth navbar scroll shadow (No breaking mobile layout or padding)
    const nav = document.getElementById('navbar');
    if (nav) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 20) {
                nav.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.06)';
            } else {
                nav.style.boxShadow = 'none';
            }
        });
    }

    // 2. Real-time article search for index.html
    const searchInput = document.getElementById('articleSearch');
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase().trim();
            const cards = document.querySelectorAll('.blog-grid .card');
            cards.forEach(card => {
                const text = card.innerText.toLowerCase();
                if (text.includes(query)) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    }

    // 3. Category filter pills for index.html
    const pills = document.querySelectorAll('.pill-filter');
    if (pills.length > 0) {
        pills.forEach(pill => {
            pill.addEventListener('click', (e) => {
                e.preventDefault();
                pills.forEach(p => {
                    p.style.backgroundColor = 'var(--surface)';
                    p.style.color = 'var(--text-muted)';
                    p.style.borderColor = 'var(--border-color)';
                });
                pill.style.backgroundColor = 'var(--primary)';
                pill.style.color = '#ffffff';
                pill.style.borderColor = 'var(--primary)';
                
                const cat = pill.getAttribute('data-cat');
                const cards = document.querySelectorAll('.blog-grid .card');
                cards.forEach(card => {
                    const tag = card.querySelector('.tag');
                    const tagText = tag ? tag.innerText.toLowerCase() : '';
                    if (cat === 'all' || tagText.includes(cat.toLowerCase())) {
                        card.style.display = 'flex';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        });
    }
});
