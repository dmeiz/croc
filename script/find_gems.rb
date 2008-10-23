require "rubygems"
require "hpricot"

$rdoc_root = "/Library/Ruby/Gems/1.8/doc"
$gems = []
$classes = {}
$methods = []

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
  rdoc_dir = File.join($rdoc_root, "#{spec.name}-#{spec.version}", "rdoc")
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
        klass[:methods] << {:name => method, :class => klass, :url => el["href"]}
      else
        puts %Q(Couldn't find class "#{$2} for method #{method}")
      end
    else
      puts %Q(Couldn't get method and class from "#{el.inner_html}")
    end
  end

  puts "Indexed #{spec.name}"
end

# mainline
get_specs[0..5].each do |spec|
  rdoc_dir = File.join($rdoc_root, "#{spec.name}-#{spec.version}", "rdoc")
  print spec.name + "..."
  if spec.has_rdoc?
    if File.exists?(rdoc_dir)
      index_gem(spec)
    else
      puts "rdocs not installed"
    end
  else
    puts "no rdocs"
  end
end

File.open("public/data.js", "w") do |f|
  f.puts       "gems = ["
  $gems.each do |gem|
    f.puts     "  {name: '#{gem[:name]}', dir: '#{gem[:dir]}', classes: ["
    gem[:classes].each_pair do |key, value|
      f.puts   "    {name: '#{key}', url: '#{value[:url]}', methods: ["
      value[:methods].each do |method|
        f.puts "      {name: '#{method[:name]}', url: '#{method[:url]}'},"
      end
      f.puts   "    ]},"
    end
    f.puts     "  ]},"
  end
  f.puts       "];"
end
