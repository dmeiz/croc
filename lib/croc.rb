require "rubygems"
require "hpricot"
require "ftools"

# Figure out where rdocs are installed.
def find_gem_home
  if File.exists?("/Library/Ruby/Gems/1.8/gems")
    return "/Library/Ruby/Gems/1.8/gems"
  end
end

# Returns the user's home directory as a string.
def user_home_dir
  ENV["HOME"]
end

# Creates ~/.croc and installs assets from public directory.
def install_assets
  croc_dir = File.join(user_home_dir, ".croc")
  unless File.exists?(croc_dir)
    Dir.mkdir(croc_dir)
    Dir.mkdir(File.join(croc_dir, "rdoc"))
  end

  public_dir = File.join(File.dirname(__FILE__), "..", "public")
  Dir.new(public_dir).each do |f|
    next if f == "." || f == ".."
    File.copy(File.join(public_dir, f), File.join(croc_dir, f))
  end
end

# Print installed gems and whether rdocs are available and indeed installed.
def print_gems
  Gem.source_index.search(nil).each do |spec|
    puts "#{spec.name} #{spec.version} #{spec.has_rdoc? ? "has rdoc" : ""} #{File.exists?(rdoc_dir) ? "and it exists" : "but it doesn't exist"}"
  end
end

# Collect specs for most recent version of all installed gems.
def get_specs
  specs = {}
  Gem.source_index.search(nil).each do |spec|
    next unless spec.has_rdoc?
    if specs[spec.name]
      specs[spec.name] = spec if (spec.version <=> specs[spec.name].version) > 0
    else
      specs[spec.name] = spec
    end
  end
  specs.values
end

# Index a gem.
def index_gem(spec)
  rdoc_dir = File.join($rdoc_home, "#{spec.name}-#{spec.version}", "rdoc")
  unless File.exists?(rdoc_dir)
    puts "WARN Couldn't find rdoc dir #{rdoc_dir}"
    return
  end

  methods_file = File.join(rdoc_dir, "fr_method_index.html")
  unless File.exists?(methods_file)
    puts "ERROR Couldn't find #{methods_file}"
  end

  classes_file = File.join(rdoc_dir, "fr_class_index.html")
  unless File.exists?(classes_file)
    puts "ERROR Couldn't find #{classes_file}"
  end

  # collect gem
  gem = {:name => spec.name, :dir => rdoc_dir, :classes => {}}
  $gems << gem

  # collect classes
  doc = Hpricot(open(classes_file))
  (doc/"#index-entries a").each do |el|
    klass = el.inner_html
  
    if $classes[klass]
      puts "Already have class #{klass}"
    else
      gem[:classes][klass] = {:name => klass, :url => el["href"], :methods => []}
    end
  end

  # collect methods
  doc = Hpricot(open(methods_file))
  (doc/"#index-entries a").each do |el|
    if el.inner_html =~ /(\S+)\s+\((\S+)\)/
      method = $1
      if klass = gem[:classes][$2]
        el["href"] =~ /#(.*)$/
        url = $1
        klass[:methods] << {:name => method, :class => klass, :url => url}
      else
        # puts %Q(Couldn't find class "#{$2} for method #{method}")
      end
    else
      # puts %Q(Couldn't get method and class from "#{el.inner_html}")
    end
  end

  puts "Indexed #{spec.name}"
end

def index_rdoc(name, rdoc_dir)
  unless File.exists?(rdoc_dir)
    puts "WARN Couldn't find rdoc dir #{rdoc_dir}"
    return
  end

  methods_file = File.join(rdoc_dir, "fr_method_index.html")
  unless File.exists?(methods_file)
    puts "ERROR Couldn't find #{methods_file}"
  end

  classes_file = File.join(rdoc_dir, "fr_class_index.html")
  unless File.exists?(classes_file)
    puts "ERROR Couldn't find #{classes_file}"
  end

  # collect gem
  gem = {:name => name, :dir => rdoc_dir, :classes => {}}
  $gems << gem

  # collect classes
  doc = Hpricot(open(classes_file))
  (doc/"#index-entries a").each do |el|
    klass = el.inner_html
  
    if $classes[klass]
      puts "Already have class #{klass}"
    else
      gem[:classes][klass] = {:name => klass, :url => el["href"], :methods => []}
    end
  end

  # collect methods
  doc = Hpricot(open(methods_file))
  (doc/"#index-entries a").each do |el|
    if el.inner_html =~ /(\S+)\s+\((\S+)\)/
      method = $1
      if klass = gem[:classes][$2]
        el["href"] =~ /#(.*)$/
        url = $1
        klass[:methods] << {:name => method, :class => klass, :url => url}
      else
        # puts %Q(Couldn't find class "#{$2} for method #{method}")
      end
    else
      # puts %Q(Couldn't get method and class from "#{el.inner_html}")
    end
  end

  puts "Indexed #{name}"
end
