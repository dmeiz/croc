require "rubygems"
require "hpricot"

doc = File.open("thor-rdoc/fr_method_index.html") do |f|
  Hpricot(f)
end

(doc/"#index-entries/a").each do |a|
  puts a
end

