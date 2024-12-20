import crypto from 'crypto';

function encrypt(data: string, key: string, iv: string): string {
  if (key.length !== 16 || iv.length !== 16) {
    throw new Error("A String Chave deve ter 16 dígitos");
  }

  const cipher = crypto.createCipheriv('aes-128-cbc', Buffer.from(key, 'utf8'), Buffer.from(iv, 'utf8'));
  let encrypted = cipher.update(data, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  return encrypted;
}

function decrypt(data: string, key: string, iv: string): string {
    if (key.length !== 16 || iv.length !== 16) {
      throw new Error("A String Chave deve ter 16 dígitos");
    }
  
    const decipher = crypto.createDecipheriv('aes-128-cbc', Buffer.from(key, 'utf8'), Buffer.from(iv, 'utf8'));
    let decrypted = decipher.update(data, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }

export default {
    encrypt,
    decrypt
}