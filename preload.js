const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  getNews: () => ipcRenderer.invoke('get-news'),
});;