require 'openssl'
require 'digest/sha2'
require 'base64'

module SymmetricFile
  # Wrapper for openssl for encrypting and decrypting with AES-256, a symmetric cypher
  # that uses the same key for both encryption and decryption.
  # 
  class Aes
    def initialize(key: "1234")
      @key = sha256(key)
    end

    def encrypt(input)
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.key = @key
      iv = cipher.random_iv
      ciphertext = cipher.update(input) + cipher.final
      cipher_msg = [encode64(iv), encode64(ciphertext)].join('$')
      hmac = calc_hmac(cipher_msg)
      [encode64(iv), encode64(ciphertext), encode64(hmac)].join("$")
    end


    def decrypt(input)
      iv64, ciphertext64, hmac64 = input.split("$")
      if calc_hmac(iv64 + "$" + ciphertext64) != decode64(hmac64)
        raise "HMAC validation failed"
      end
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.decrypt
      cipher.key = @key
      cipher.iv = decode64(iv64)
      cipher.update(decode64(ciphertext64)) + cipher.final
    end

    private

    def decode64(input)
      Base64.decode64(input)
    end

    def encode64(input)
      Base64.encode64(input).strip
    end

    def calc_hmac(input)
      OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, @key, input)
    end

    def sha256(phrase)
      digest = Digest::SHA256.new
      digest.update(phrase)
      digest.digest
    end
  end
end
