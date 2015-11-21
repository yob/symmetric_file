require 'openssl'
require 'digest/sha2'
require 'base64'

module SymmetricFile
  # Wrapper for openssl for encrypting and decrypting with AES-256, a symmetric cypher
  # that uses the same key for both encryption and decryption.
  # 
  class Aes
    SEPERATOR = "--"

    def initialize(key: "1234")
      @key = sha256(key)
    end

    def encrypt(input)
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.key = @key
      iv = cipher.random_iv
      ciphertext = cipher.update(input) + cipher.final
      cipher_msg = [encode64(iv), encode64(ciphertext)].join(SEPERATOR)
      hmac = calc_hmac(cipher_msg)
      [encode64(iv), encode64(ciphertext), encode64(hmac)].join(SEPERATOR)
    end


    def decrypt(input)
      iv64, ciphertext64, hmac64 = input.to_s.split(SEPERATOR)
      if iv64.nil? || ciphertext64.nil? || hmac64.nil?
        raise InputError, "Input not a recogised format"
      elsif calc_hmac(iv64 + SEPERATOR + ciphertext64) != decode64(hmac64)
        raise InputError, "HMAC validation failed. The passphrase may be incorrect or the encrypted message may have been tampered with"
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
