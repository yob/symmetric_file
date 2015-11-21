require 'shellwords'

module SymmetricFile
  class MergeCommand
    def initialize(key: nil)
      @cipher = SymmetricFile::Aes.new(key: key)
    end

    def run(mine_path, old_path, yours_path)
      mine = Tempfile.open('mine')
      old = Tempfile.open('old')
      yours = Tempfile.open('yours')

      begin
        # decrypt all three of our files
        mine.write @cipher.decrypt(read_file(mine_path))
        old.write @cipher.decrypt(read_file(old_path))
        yours.write @cipher.decrypt(read_file(yours_path))

        # flush our io
        mine.flush
        old.flush
        yours.flush

        cmd = "git merge-file -L mine -L old -L yours -p %s %s %s  2>/dev/null" %
          [ Shellwords.escape(mine.path), Shellwords.escape(old.path), Shellwords.escape(yours.path)]

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
        t.write @cipher.encrypt(diff)
        t.flush

        # and copy that file back to old_path since that's where git expects to find it
        FileUtils.copy t.path, old_path
      ensure
        t.close!
      end

      # this is important - this exit value is what git uses to decide if there
      # is a conflict or not
      exit (conflict ? 1 : 0)
    end

    private

    def read_file(path)
      File.binread(path)
    rescue Errno::ENOENT
      raise SymmetricFile::InputError, "file '#{path}' not found"
    end
  end
end
