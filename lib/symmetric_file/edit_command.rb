require 'shellwords'

module SymmetricFile
  class EditCommand
    def initialize(key: nil, editor: nil)
      @editor = editor || "vim"
      @cipher = SymmetricFile::Aes.new(key: key)
    end

    def run(encrypted_path)
      temp = Tempfile.new([File.basename(encrypted_path), ".tmp"])
      if File.file?(encrypted_path)
        data = read_file(encrypted_path)
        temp.write @cipher.decrypt(data)
        temp.flush
      end
      temp.close(false)

      unless system("#{@editor} #{Shellwords.escape(temp.path)}")
        raise SymmetricFile::EditError, "User aborted edit"
      end
      File.open(encrypted_path, "wb") do |io|
        io.write @cipher.encrypt(read_file(temp.path))
      end
    ensure
      temp.close! if temp
    end

    private

    def read_file(path)
      File.binread(path)
    rescue Errno::ENOENT
      raise SymmetricFile::InputError, "file '#{path}' not found"
    end
  end
end
