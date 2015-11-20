module SymmetricFile
  class File
    def initialize(io, key: "")
      @io = io
      @cipher = Aes.new(key: key)
    end

    def cat
      @cipher.decrypt(@io.read)
    end
  end
end
