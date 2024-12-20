const worker = new Worker('rsa_worker.js');

self.onmessage = (event) => {
  worker.postMessage(event.data);
};

worker.onmessage = (event) => {
  self.postMessage(event.data);
};