require 'tempfile'

module SymmetricFile
  class Cli

    def cat(encrypted_path)
      SymmetricFile::CatCommand.new(key: key).run(read_file(encrypted_path))
    end

    def edit(encrypted_path)
      SymmetricFile::EditCommand.new(
        key: key,
        editor: detect_editor,
      ).run(encrypted_path)
    end

    def merge(mine_path, old_path, yours_path)
      SymmetricFile::MergeCommand.new(key: key).run(mine_path, old_path, yours_path)
    end

    private

    # This method copied directly from Pry and is
    # Copyright (c) 2013 John Mair (banisterfiend)
    # https://github.com/pry/pry/blob/master/LICENSE
    def detect_editor
      configured = ENV["VISUAL"] || ENV["EDITOR"] || guess_editor
      configured = configured.dup
      case configured
      when /^mate/, /^subl/
        configured << " -w"
      when /^[gm]vim/
        configured << " --nofork"
      when /^jedit/
        configured << " -wait"
      end

      configured
    end

    def guess_editor
      %w(subl sublime-text sensible-editor editor mate nano vim vi open).detect do |editor|
        system("command -v #{editor} > /dev/null 2>&1")
      end
    end

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
