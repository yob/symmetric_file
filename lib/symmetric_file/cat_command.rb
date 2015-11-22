module SymmetricFile
  class CatCommand
    def initialize(key: "", output: $stdout)
      @output = output
      @key = key
    end

    def run(encrypted_data)
      cipher = SymmetricFile::Aes.new(key: @key)
      @output.puts cipher.decrypt(encrypted_data)
    end

  end
end
