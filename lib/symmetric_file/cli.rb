require 'tempfile'

module SymmetricFile
  class Cli

    def cat(encrypted_path)
      SymmetricFile::CatCommand.new(key: key).run(read_file(encrypted_path))
    end

    def edit(encrypted_path)
      SymmetricFile::EditCommand.new(key: key).run(encrypted_path)
    end

    def merge(mine_path, old_path, yours_path)
      SymmetricFile::MergeCommand.new(key: key).run(mine_path, old_path, yours_path)
    end

    private

    def read_file(path)
      File.binread(path)
    rescue Errno::ENOENT
      raise SymmetricFile::InputError, "file '#{path}' not found"
    end

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
