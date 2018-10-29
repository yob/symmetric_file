Gem::Specification.new do |s|
  s.name              = "symmetric_file"
  s.version           = "0.1.0"
  s.summary           = "Create and edit encrypted text files"
  s.description       = "Simple management of encrypted text files - particularly useful for use with ruby projects stored in git. Uses AES-CBC with HMAC authentication."
  s.authors           = ["James Healy"]
  s.email             = ["james.healy@theconversation.edu.au"]
  s.homepage          = "http://github.com/yob/symmetric_file"
  s.rdoc_options      << "--title" << "SymmetricFile" << "--line-numbers"
  s.files             =  Dir.glob("{lib,bin}/**/*") + ["README.markdown","MIT-LICENSE","CHANGELOG"]
  s.executables       = ["symmetric-file"]
  s.license           = "MIT"

  s.add_development_dependency("rake", "~> 10.0")
  s.add_development_dependency("rspec", "~>3.0")
  s.add_development_dependency("pry", "~> 0.11")
end

