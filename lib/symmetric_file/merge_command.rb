module SymmetricFile
  class MergeCommand
    def initialize(key: nil)
      @key = key
    end

    def run(encrypted_path)
      mine = Tempfile.open('mine')
      old = Tempfile.open('old')
      yours = Tempfile.open('yours')

      begin
        # decrypt all three of our files
        cipher = SymmetricFile::Aes.new(key: @key)
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
  end
end
