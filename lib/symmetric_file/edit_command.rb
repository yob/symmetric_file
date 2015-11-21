module SymmetricFile
  class EditCommand
    def initialize(key: nil)
      @key = key
    end

    def run(encrypted_path)
      temp = Tempfile.new([File.basename(encrypted_path), ".tmp"])
      if File.file?(encrypted_path)
        data = read_file(encrypted_path)
        cipher = SymmetricFile::Aes.new(key: @key)
        temp.write cipher.decrypt(data)
        temp.flush
      end
      temp.close(false)

      # TODO escape the path to avoid security issues
      system "vim #{temp.path}"

      if $?.success?
        temp.open
        temp.seek(0)
        File.open(encrypted_path, "wb") do |io|
          io.write SymmetricFile::Aes.new(key: @key).encrypt(temp.read)
        end
      else
        $stderr.puts "Failed writing new file"
      end
    ensure
      if temp
        temp.close
        temp.unlink
      end
    end

    private

    def read_file(path)
      File.binread(path)
    rescue Errno::ENOENT
      raise SymmetricFile::InputError, "file '#{path}' not found"
    end
  end
end
