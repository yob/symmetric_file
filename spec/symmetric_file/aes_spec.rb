RSpec.describe SymmetricFile::Aes do
  let(:key) { "1234" }
  let(:aes) { SymmetricFile::Aes.new(key: key) }

  describe "Cleartext Round trip" do
    let(:cleartext) { "Test" }

    context "with a short cleartext" do
      let(:encrypted_msg) { aes.encrypt(cleartext)} 
      let(:decrypted_msg) { aes.decrypt(encrypted_msg) }

      it "survives" do
        expect(decrypted_msg).to eq cleartext
      end
    end
    context "with a long cleartext" do
      let(:cleartext) { SecureRandom.hex(5000) }
      let(:encrypted_msg) { aes.encrypt(cleartext)} 
      let(:decrypted_msg) { aes.decrypt(encrypted_msg) }

      it "survives" do
        expect(decrypted_msg).to eq cleartext
      end
    end
  end

  describe "#encrypt" do
    let(:cleartext) { "Test" }
    let(:encrypted_msg) { aes.encrypt(cleartext)} 

    context "when encrypting 'Test'" do
      it "is marked as version 3 of RNCryptor" do
        expect(encrypted_msg[0,1]).to eq "\x03"
      end
      it "is exactly 82 bytes" do
        expect(encrypted_msg.bytesize).to eq 82
      end
      it "is marked as binary" do
        expect(encrypted_msg.encoding).to eq Encoding.find("binary")
      end
    end
    context "when the same cleartext is encrypted twice" do
      let(:encrypted_msg_one) { aes.encrypt(cleartext)} 
      let(:encrypted_msg_two) { aes.encrypt(cleartext)} 

      it "encrypts differently each time" do
        expect(encrypted_msg_one).to_not eq encrypted_msg_two
      end
    end
  end

  describe "#decrypt" do
    context "when the input data is 66 bytes" do
      let(:encrypted_msg) { "a" * 66 }
      
      it "raises InputError" do
        expect {
          aes.decrypt(encrypted_msg)
        }.to raise_error(SymmetricFile::InputError, "Encrypted data too short")
      end
    end
    context "when the input data doesn't indicate v3 of RNCryptor" do
      let(:encrypted_msg) { "\x02" + ("a" * 66) }
      
      it "raises InputError" do
        expect {
          aes.decrypt(encrypted_msg)
        }.to raise_error(SymmetricFile::InputError, "Only version 3 data can be decrypted")
      end
    end
    context "when the input data doesn't have a valid HMAC" do
      let(:encrypted_msg) { "\x03" + ("a" * 67) }
      
      it "raises InputError" do
        expect {
          aes.decrypt(encrypted_msg)
        }.to raise_error(SymmetricFile::InputError, "HMAC validation failed. The passphrase may be incorrect or the encrypted message may have been tampered with")
      end
    end
    context "when the provided key is wrong" do
      let(:encrypted_msg) { aes.encrypt("Test") }
      let(:aes_with_wrong_key) { SymmetricFile::Aes.new(key: "000") }
      
      it "raises InputError" do
        expect {
          aes_with_wrong_key.decrypt(encrypted_msg)
        }.to raise_error(SymmetricFile::InputError, "HMAC validation failed. The passphrase may be incorrect or the encrypted message may have been tampered with")
      end
    end
    context "with valid v3 message" do
      let(:encrypted_hex) {
        "0301835b93e734143340ca8b55fc77865be906abe119073b77d5bc46" +
        "1fcc8bc8aea42fde3eb01b33bd3b54f2d58aaaef7747d24e1bde83aa" +
        "b5f81d7e68e3e2ba6c4f1420b638faea3d6dec7c801345d5bc059289" +
        "f52b4d030786fc11e22a3939efd7c88a6cad3e23a9fc87e6bbfbc389" +
        "01525b2ef7384045923260b3928a5bedbf7b"
      }
      let(:encrypted_msg) { [encrypted_hex].pack("H*") }
      let(:aes) { SymmetricFile::Aes.new(key: "P@ssw0rd!") }
      
      it "returns a message" do
        expect(aes.decrypt(encrypted_msg)).to eq "Hello, World! Let's use a few blocks with a longer sentence."
      end
    end
    context "with valid v3 message" do
      let(:encrypted_hex) {
        "0301835b93e734143340ca8b55fc77865be906abe119073b77d5bc46" +
        "1fcc8bc8aea42fde3eb01b33bd3b54f2d58aaaef7747d24e1bde83aa" +
        "b5f81d7e68e3e2ba6c4f1420b638faea3d6dec7c801345d5bc059289" +
        "f52b4d030786fc11e22a3939efd7c88a6cad3e23a9fc87e6bbfbc389" +
        "01525b2ef7384045923260b3928a5bedbf7b"
      }
      let(:encrypted_msg) { [encrypted_hex].pack("H*") }
      let(:aes) { SymmetricFile::Aes.new(key: "P@ssw0rd!") }
      
      it "returns a message" do
        expect(aes.decrypt(encrypted_msg)).to eq "Hello, World! Let's use a few blocks with a longer sentence."
      end
    end

  end

end
