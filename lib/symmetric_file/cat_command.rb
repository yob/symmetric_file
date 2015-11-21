module SymmetricFile
  class CatCommand
    def initialize(key: "")
      @key = key
    end

    def run(encrypted_path)
      if encrypted_path.nil? || !::File.file?(encrypted_path)
        $stderr.puts "#{encrypted_path} not found"
        exit(1)
      end

      ::File.open(encrypted_path, "rb") do |io|
        file = SymmetricFile::File.new(io, key: @key)
        puts file.cat
      end
    end
  end
end
