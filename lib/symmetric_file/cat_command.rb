module SymmetricFile
  class CatCommand
    def initialize(key: "")
      @key = key
    end

    def run(encrypted_path)
      data = read_file(encrypted_path)
      cipher = SymmetricFile::Aes.new(key: @key)
      puts cipher.decrypt(data)
    end

    private

    def read_file(path)
      ::File.binread(path)
    rescue Errno::ENOENT
      raise SymmetricFile::InputError, "file '#{path}' not found"
    end
  end
end