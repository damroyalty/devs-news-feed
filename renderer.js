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

// Add to renderer.js for client-side analysis
function analyzeSentiment(headline) {
    const positive = ['up', 'rise', 'gain', 'bullish'];
    const negative = ['down', 'fall', 'drop', 'bearish'];
    
    let score = 0;
    const words = headline.toLowerCase().split(/\s+/);
    words.forEach(word => {
      if (positive.includes(word)) score++;
      if (negative.includes(word)) score--;
    });
    
    return score > 0 ? '📈' : score < 0 ? '📉' : '➖';
  }
  
  // Apply to each article title
  contentDiv.innerHTML += `<span class="sentiment">${analyzeSentiment(article.title)}</span>`;

  function analyzeSentiment(headline) {
    // More sophisticated analysis can be implemented here
    const positive = ['up', 'rise', 'gain', 'bullish'];
    const negative = ['down', 'fall', 'drop', 'bearish'];
    
    let score = 0;
    const words = headline.toLowerCase().split(/\s+/);
    words.forEach(word => {
      if (positive.includes(word)) score++;
      if (negative.includes(word)) score--;
    });
    
    return score > 0 ? '📈' : score < 0 ? '📉' : '➖';
  }
  
  async function displayEarnings() {
    const earningsData = await fetchEarningsCalendar();
    const earningsList = document.getElementById('earnings-list');
    earningsData.forEach(earn => {
      const listItem = document.createElement('li');
      listItem.innerHTML = `${earn.symbol} - ${earn.earningsDate}`;
      earningsList.appendChild(listItem);
    });
  }
  

function createHeadlineTicker(newsItems) {
    const ticker = document.querySelector('.headline-scroll');
    if (!ticker) return;
    
    ticker.innerHTML = '';
    
    // for financial headlines 
    const financialKeywords = ['stock', 'stocks', 'market', 'dow', 'nasdaq', 's&p', 
                             'earnings', 'profit', 'revenue', 'investment', 'share'];
    
    const financialNews = newsItems.filter(item => 
      financialKeywords.some(keyword => 
        item.title.toLowerCase().includes(keyword.toLowerCase())
      )
    );
    
    // ticker items
    financialNews.forEach(item => {
      const sentiment = analyzeSentiment(item.title);
      const tickerItem = document.createElement('span');
      tickerItem.className = 'headline-item';
      
      tickerItem.innerHTML = `
        <span class="${sentiment === '📈' ? 'positive' : sentiment === '📉' ? 'negative' : ''}">
          ${sentiment} ${item.title} 
        </span>
        <span style="color: #82dce2; margin: 0 10px;">|</span>
      `;
      
      ticker.appendChild(tickerItem);
    });
    
    // Add some empty space at the end
    const spacer = document.createElement('span');
    spacer.className = 'headline-item';
    spacer.innerHTML = '•••';
    ticker.appendChild(spacer.cloneNode());
    ticker.appendChild(spacer.cloneNode());
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
  
      createHeadlineTicker(data.articles);
  
    
      const fragment = document.createDocumentFragment();
      
    
      
      feed.appendChild(fragment);
      updateTimestamp();
    } catch (err) {
      console.error('Error fetching news:', err);
      feed.innerHTML = `<li>Error: ${err.message}</li>`;
    }
  }
  
 
  function analyzeSentiment(headline) {
    const positive = ['up', 'rise', 'gain', 'bullish', 'beat', 'surge', 'high', 'increase'];
    const negative = ['down', 'fall', 'drop', 'bearish', 'miss', 'plunge', 'low', 'decrease'];
    
    let score = 0;
    const words = headline.toLowerCase().split(/\s+/);
    
    words.forEach(word => {
      if (positive.includes(word)) score++;
      if (negative.includes(word)) score--;
    });
    
    return score > 0 ? '📈' : score < 0 ? '📉' : '➖';
  }


 document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('news-search');
    const searchButton = document.getElementById('search-button');
  
    // Search function
    const performSearch = async () => {
      const query = searchInput.value.trim();
      if (!query) {
        await loadDefaultNews();
        return;
      }
  
      searchButton.innerHTML = '<div class="spinner"></div>';
      searchButton.disabled = true;
  
      try {
        const result = await window.api.searchNews(query);
        
        if (result.status === 'success' && result.articles.length > 0) {
          displayNews(result.articles);
        } else {
          feed.innerHTML = `<li class="error">${result.message || 'No articles found'}</li>`;
        }
      } catch (error) {
        console.error('Search error:', error);
        feed.innerHTML = `<li class="error">Search failed: ${error.message}</li>`;
      } finally {
        searchButton.innerHTML = '🔍';
        searchButton.disabled = false;
      }
    };
  
    const displayNews = (articles) => {
      feed.innerHTML = '';
  
      articles.forEach(article => {
        const li = document.createElement('li');
        li.innerHTML = `
          <img src="${article.urlToImage || FALLBACK_IMAGE}" alt="${article.title}">
          <div>
            <strong>${article.title}</strong>
            <em>${article.source} • ${formatDate(article.publishedAt)}</em>
            <p>${article.description || ''}</p>
            <a href="${article.url}" target="_blank" rel="noopener">Read more</a>
            <span class="sentiment">${article.sentiment}</span>
          </div>
        `;
        feed.appendChild(li);
      });
    };
  
    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    };
  
    const loadDefaultNews = async () => {
      const result = await window.api.getNews();
      displayNews(result.articles || []);
    };
  
    searchButton.addEventListener('click', performSearch);
    searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') performSearch();
    });
  
    loadDefaultNews();
  });
