require 'tempfile'

module SymmetricFile
  class Cli

    def cat(encrypted_path)
      if encrypted_path.nil? || !::File.file?(encrypted_path)
        $stderr.puts "#{encrypted_path} not found"
        exit(1)
      end

      ::File.open(encrypted_path, "rb") do |io|
        file = SymmetricFile::File.new(io, key: key)
        puts file.cat
      end
    end

    def edit(encrypted_path)
      temp = Tempfile.new([::File.basename(encrypted_path), ".sh"])
      if ::File.file?(encrypted_path)
        ::File.open(encrypted_path, "rb") do |io|
          file = SymmetricFile::File.new(io, key: key)
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
          io.write SymmetricFile::Aes.new(key: key).encrypt(temp.read)
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

    # TODO merge()

    private

    def key
      @key ||= read_key("Enter key:")
    end

    def read_input(prompt)
      $stderr.print prompt
      $stderr.flush
      $stdin.readline.strip
    end

    def read_key(prompt)
      `stty -echo`
      read_input prompt
    ensure
      $stderr.print "\n"
      `stty echo`
    end
  end
end
