if (typeof window === 'undefined') {
  // Redefine window como self para compatibilidade
  self.window = self;
}

importScripts('forge.min.js');

self.onmessage = async function (e) {
    const forge = self.forge;
    const rsa = forge.pki.rsa;
  
    rsa.generateKeyPair({bits: 2048, workers: 1}, (err, keypair) => {
      if (err) {
        self.postMessage({error: err.message});
        return;
      }
  
      const publicKeyPem = forge.pki.publicKeyToPem(keypair.publicKey);
      const privateKeyPem = forge.pki.privateKeyToPem(keypair.privateKey);
  
      self.postMessage({
        publicKey: publicKeyPem,
        privateKey: privateKeyPem,
      });
    });
  };
  