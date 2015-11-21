module SymmetricFile
  class EditCommand
    def initialize(key: nil)
      @key = key
    end

    def run(encrypted_path)
      temp = Tempfile.new([::File.basename(encrypted_path), ".sh"])
      if ::File.file?(encrypted_path)
        ::File.open(encrypted_path, "rb") do |io|
          file = SymmetricFile::File.new(io, key: @key)
          temp.write file.cat
        end
        temp.flush
      end
      temp.close(false)

      # TODO escape the path to avoid security issues
      system "vim #{temp.path}"

      if $?.success?
        temp.open
        temp.seek(0)
        ::File.open(encrypted_path, "wb") do |io|
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
  end
end
