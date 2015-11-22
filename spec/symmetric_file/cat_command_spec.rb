RSpec.describe SymmetricFile::CatCommand do
  let(:key) { "1234" }
  let(:stdout) { double($stdout, puts: true) }
  let(:command) { SymmetricFile::CatCommand.new(key: key, output: stdout) }

  describe "#run" do
    let(:aes) { instance_double(SymmetricFile::Aes)}
    before do
      allow(SymmetricFile::Aes).to receive(:new) { aes }
    end

    context "when the input data can be decrypted" do
      before do
        allow(aes).to receive(:decrypt) { "1234" } 
      end
      it "prints the cleartext to output" do
        command.run("encrypted")
        expect(stdout).to have_received(:puts).with("1234")
      end
    end
    context "when the input data can't be decrypted" do
      before do
        allow(aes).to receive(:decrypt).and_raise(SymmetricFile::InputError)
      end
      it "raises an exception" do
        expect {
          command.run("encrypted")
        }.to raise_error(SymmetricFile::InputError)
      end
    end
  end

end
