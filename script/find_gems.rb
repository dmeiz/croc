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
  $gems << {:name => spec.name, :dir => rdoc_dir}

  # collect classes
  doc = Hpricot(open(classes_file))
  (doc/"#index-entries a").each do |el|
    klass = el.inner_html
  
    if $classes[klass]
      puts "Already have class #{klass}"
    else
      $classes[klass] = {:name => klass, :url => el["href"]}
    end
  end

  puts "Got #{$classes.length} classes"

  # collect methods
  doc = Hpricot(open(methods_file))
  (doc/"#index-entries a").each do |el|
    if el.inner_html =~ /(\S+)\s+\((\w+)\)/
      method = $1
      if klass = $classes[$2]
        $methods << {:name => method, :class => klass, :url => el["href"]}
      else
        puts %Q(Couldn't find class "#{$2} for method #{method}")
      end
    else
      puts %Q(Couldn't get method and class from "#{el.inner_html}")
    end
  end

  puts "Indexed #{spec.name}, got #{$classes.length} classes and #{$methods.length} methods"
end

# mainline

index_gem(Gem.source_index.search(nil)[0])

File.open("public/search.html", "w") do |f|
  f.puts "<html>"
  f.puts "<head>"
  f.puts "<script>"

  f.puts "  gems = ["
  $gems.each do |gem|
  f.puts "    {'name': '#{gem[:name]}': {dir: '#{gem[:dir]}'},"
  end
  f.puts "  ];"

  f.puts "  classes = {"
  $classes.each_pair do |key, value|
  f.puts "    '#{key}': {url: '#{value[:url]}'},"
  end
  f.puts "  };"

  f.puts "  methods = {"
  $methods.each do |method|
  f.puts "    '#{method[:name]}': {url: '#{method[:url]}', class: '#{method[:class][:name]}'},"
  end
  f.puts "  };"

  f.puts "</script>"
  f.puts "</head>"
  f.puts "<body/>"
  f.puts "</html>"
end
