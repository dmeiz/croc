require "rubygems"

def find_doc_root
  puts Gem.source_index.search(nil)[0].methods
end

#find_doc_root
$rdoc_root = "/Library/Ruby/Gems/1.8/doc"
Gem.source_index.search(nil).each do |spec|
  rdoc_dir = File.join($rdoc_root, "#{spec.name}-#{spec.version}")
  
  puts "#{spec.name} #{spec.version} #{spec.has_rdoc? ? "rdoc" : ""} #{File.exists?(rdoc_dir) ? "exists" : ""}"
end
