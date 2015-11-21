require 'openssl'
require 'digest/sha2'
require 'securerandom'

module SymmetricFile
  # Wrapper for openssl for encrypting and decrypting with AES-256, a symmetric cypher
  # that uses the same key for both encryption and decryption.
  #
  class Aes
    SEPERATOR = "--"

    def initialize(key: "1234")
      @key = key
    end

    def encrypt(input)
      version = 3.chr
      options = 1.chr # uses password
      encryption_salt = SecureRandom.random_bytes(8)
      hmac_salt = SecureRandom.random_bytes(8)
      hmac_key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@key , hmac_salt, 10000, 32)

      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@key, encryption_salt, 10000, 32)
      iv = cipher.random_iv
      ciphertext = cipher.update(input.to_s) + cipher.final
      msg = version + options + encryption_salt + hmac_salt + iv + ciphertext
      hmac = [OpenSSL::HMAC.hexdigest('sha256', hmac_key, msg)].pack('H*')
      msg + hmac
    end

    def decrypt(input)
      raise InputError, "Encrypted data too short" unless input.bytesize >= 67

      version         = input[0,1]
      options         = input[1,1]
      encryption_salt = input[2,8]
      hmac_salt       = input[10,8]
      iv              = input[18,16]
      ciphertext      = input[34, input.bytesize-66]
      hmac            = input[-32, 32]

      raise InputError, "Only version 3 data can be decrypted" unless version == "\x03"

      msg = version + options + encryption_salt + hmac_salt + iv + ciphertext

      hmac_key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@key, hmac_salt, 10000, 32)
      verified = [OpenSSL::HMAC.hexdigest('sha256', hmac_key, msg)].pack('H*') == hmac

      unless verified
        raise InputError, "HMAC validation failed. The passphrase may be incorrect or the encrypted message may have been tampered with"
      end

      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.decrypt
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(@key, encryption_salt, 10000, 32)
      cipher.iv = iv
      cipher.update(ciphertext) + cipher.final
    end

  end
end
