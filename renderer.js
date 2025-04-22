document.addEventListener('DOMContentLoaded', async () => {
    const feed = document.getElementById('news-feed');
    const REFRESH_MS = 15_000; // Refresh every 15 seconds
    const fallbackImage = 'https://preview.redd.it/where-is-uuh-from-does-anyone-know-the-origin-v0-bm1xva9aq59c1.gif?format=png8&s=4ca27bed5952dfd90b6f36dea8cf5bd7797eac93';

    // Create and style timestamp element
    const timestamp = document.createElement('div');
    Object.assign(timestamp.style, {
        position: 'absolute',
        top: '10px',
        right: '10px',
        color: '#ffffff',
        fontSize: '12px',
        zIndex: '1000',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        padding: '4px 8px',
        borderRadius: '4px'
    });
    timestamp.id = 'last-updated';
    document.body.appendChild(timestamp);

    function updateTimestamp() {
        const now = new Date();
        timestamp.textContent = `Updated: ${now.toLocaleTimeString()}`;
    }

    async function fetchNews() {
        try {
            updateTimestamp();
            const data = await window.api.getNews();
            
            if (!feed) return;
            feed.innerHTML = '';
            
            if (data.error) {
                feed.innerHTML = `<li>Error: ${data.error}</li>`;
                return;
            }

            const fragment = document.createDocumentFragment();

            for (const article of data.articles) {
                const li = document.createElement('li');
                const imgContainer = document.createElement('div');
                imgContainer.className = 'img-container loading';
                
                const img = new Image(); // Better than createElement('img')
                img.className = 'news-thumbnail';
                img.alt = article.title || 'News thumbnail';
                img.loading = 'lazy';
                img.decoding = 'async';

                // Image handling with cache busting
                const imageUrl = article.urlToImage ? 
                    `${article.urlToImage}?t=${Date.now()}` : 
                    fallbackImage;

                // Set up loading state
                img.onload = () => {
                    imgContainer.classList.remove('loading');
                    img.classList.add('loaded');
                };

                img.onerror = () => {
                    imgContainer.classList.remove('loading');
                    img.src = fallbackImage;
                    img.onerror = null;
                };

                // Start loading
                img.src = imageUrl;

                // Create content with preview
                const contentDiv = document.createElement('div');
                contentDiv.innerHTML = `
                    <strong>${article.title || 'No title'}</strong>
                    <em>${article.source?.name || 'Unknown source'}</em>
                    <div class="article-preview">${truncateText(article.description || article.content || '', 200)}</div>
                    <br><a href="${article.url || '#'}" target="_blank" rel="noopener">Read more</a>
                `;

                // Click handler for preview
                li.addEventListener('click', (e) => {
                    if (!e.target.closest('a')) { // Better link detection
                        li.classList.toggle('active');
                    }
                });

                imgContainer.appendChild(img);
                li.append(imgContainer, contentDiv);
                fragment.appendChild(li);
            }

            feed.appendChild(fragment);
            updateTimestamp();
        } catch (err) {
            console.error('Error fetching news:', err);
            feed.innerHTML = `<li>Error: ${err.message}</li>`;
        }
    }

    // Helper function to truncate text
    function truncateText(text, maxLength) {
        return text?.length > maxLength ? 
            `${text.substring(0, maxLength)}...` : 
            text || 'No description available';
    }

    // Initial load
    await fetchNews();

    // Refresh interval with cleanup
    const refreshInterval = setInterval(fetchNews, REFRESH_MS);
    window.addEventListener('unload', () => clearInterval(refreshInterval));
});