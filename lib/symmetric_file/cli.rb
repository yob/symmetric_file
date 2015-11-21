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

    def merge(mine_path, old_path, yours_path)
      mine = Tempfile.open('mine')
      old = Tempfile.open('old')
      yours = Tempfile.open('yours')

      begin
        # decrypt all three of our files
        cipher = SymmetricFile::Aes.new(key: key)
        mine.write cipher.decrypt(::File.read(mine_path))
        old.write cipher.decrypt(::File.read(old_path))
        yours.write cipher.decrypt(::File.read(yours_path))

        # flush our io
        mine.flush
        old.flush
        yours.flush

        cmd = "git merge-file -L mine -L old -L yours -p %s %s %s  2>/dev/null" %
          [ mine.path, old.path, yours.path]

        # TODO fix escaping to ensure no security issues
        diff = `#{cmd}`
        conflict = !$?.success?
      ensure
        # close and unlink our tempfiles
        mine.close!
        old.close!
        yours.close!
      end

      #  create a new tempfile to write our merged file to
      t = Tempfile.open('merged')

      begin
        # encrypt our diff3 output
        t.write cipher.encrypt(diff)
        t.flush

        # and copy that file back to OLDFILE (aka files[1]) since that's where
        # git expects to find it
        FileUtils.copy t.path, old_path
      ensure
        t.close!
      end

      # this is important - this exit value is what git uses to decide if there
      # is a conflict or not
      exit (conflict ? 1 : 0)
    end

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
