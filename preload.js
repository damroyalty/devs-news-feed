const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  searchNews: (query) => ipcRenderer.invoke('search-news', query),
  getNews: () => ipcRenderer.invoke('get-news'),
});
