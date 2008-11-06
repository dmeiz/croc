require "rake"

Gem::Specification.new do |spec|
  spec.name = "croc"
  spec.version = "0.9.1"
  spec.date = Time.now
  spec.authors = "Dan Hensgen"
  spec.bindir = "bin" 
  spec.executables = ["croc"]
  spec.email = "dan@methodhead.com"
  spec.summary = "Index and searches local rdocs"
  spec.description = %q{Indexes local rdocs and generates a web page to search and display gems, classes and methods.}
  spec.files = FileList["lib/*", "bin/*", "public/*", "README"]
end 
