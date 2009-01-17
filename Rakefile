# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'croc'

task :default => 'spec:run'

PROJ.name = 'croc'
PROJ.authors = 'Dan Hensgen'
PROJ.email = 'dan@methodhead.com'
PROJ.url = 'https://rubyforge.org/projects/croc/'
PROJ.version = "1.0.0"
PROJ.rubyforge.name = 'croc'

PROJ.spec.opts << '--color'
PROJ.exclude << "bugs" << "\.sw.$" << ".ditz-config"

# EOF
