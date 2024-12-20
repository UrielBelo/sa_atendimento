import * as forge from "node-forge";

class RSA {
  private chunkSize: number;

  constructor() {
    this.chunkSize = 64; // RSA-OAEP usa padding maior, ajusta o tamanho do bloco
  }

  generateKeyPair(): { publicKey: string; privateKey: string } {
    const keypair = forge.pki.rsa.generateKeyPair({ bits: 2048 });
    const publicKey = forge.pki.publicKeyToPem(keypair.publicKey);
    const privateKey = forge.pki.privateKeyToPem(keypair.privateKey);
    return { publicKey, privateKey };
  }

  decipherWithPrivateKey(encrypted: string, privateKeyPem: string): string {
    const privateKey = forge.pki.privateKeyFromPem(privateKeyPem);

    const encryptedBlocks = encrypted.split('|');
    let decryptedText = '';
    for(const block of encryptedBlocks){
      if(block.trim() !== '') {
        const decryptedBlock = privateKey.decrypt(block, "RSA-OAEP")
        decryptedText += decryptedBlock
      }
    }

    return decryptedText
  }

  cipherWithPublicKey(message: string, publicKeyPem: string): string {
    const publicKey = forge.pki.publicKeyFromPem(publicKeyPem.trim());
    const blocks = this.splitStringInBlocks(message)
    let encryptedString = '';

    for(const block of blocks){
      const encryptedBlock = publicKey.encrypt(forge.util.decodeUtf8(block), "RSA-OAEP")
      encryptedString += `${forge.util.bytesToHex(encryptedBlock)}|`
    }

    return encryptedString
  }

  private splitStringInBlocks(data:string):string[] {
    const blocks:string[] = []
    for(let i = 0; i < data.length; i += this.chunkSize) {
      blocks.push(data.substring(i, i + this.chunkSize > data.length ? data.length : i + this.chunkSize))
    }
    return blocks
  }
}

export default RSA;