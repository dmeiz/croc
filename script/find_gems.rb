require "rubygems"
require "hpricot"

$rdoc_root = "/Library/Ruby/Gems/1.8/doc"
$methods = []
$classes = []

# Print installed gems and whether rdocs are available and indeed installed.
def print_gems
  Gem.source_index.search(nil).each do |spec|
    puts "#{spec.name} #{spec.version} #{spec.has_rdoc? ? "has rdoc" : ""} #{File.exists?(rdoc_dir) ? "and it exists" : "but it doesn't exist"}"
  end
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

  doc = Hpricot(open(methods_file))
  (doc/"#index-entries a").each do |el|
puts el
    if el.inner_html =~ /(\S+)\s+\((\w+)\)/
      method = $1
      klass = $2
      methods << {:name => method, :class => klass}
    else
      puts %Q(Couldn't get method and class from "#{el.inner_html}")
    end
  end

  puts "Got #{methods.length} methods"
end

# mainline

index_gem(Gem.source_index.search(nil)[0])
