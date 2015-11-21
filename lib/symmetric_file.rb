require 'symmetric_file/aes'
require 'symmetric_file/cli'
require 'symmetric_file/cat_command'
require 'symmetric_file/edit_command'
require 'symmetric_file/merge_command'

module SymmetricFile
  InputError = Class.new(StandardError)
  EditError = Class.new(StandardError)
end
