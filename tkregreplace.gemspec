require 'rubygems'

spec = Gem::Specification.new do |s|
    s.name          = "tkregreplace"
    s.version       = "0.1.2"
    s.author        = "Gary Watson"
    s.email         = "gary.d.watson@gmail.com"
    s.platform      = Gem::Platform::RUBY
    s.summary       = "TK program which visualizes and caries out regular expression matches and or replacements on text files"
    s.files         = ["tkregreplace.rb", "README.txt"]# + Dir.glob("{docs}/**/*").delete_if {|item| item.include?("CVS") || item.include?("rdoc")}
    s.extra_rdoc_files = ["README.txt"]
    s.bindir        = "."
    s.executables   = ['tkregreplace.rb']
    s.has_rdoc      = true
    s.extra_rdoc_files = ["README.txt"]
    s.require_path  = '.' 
end

if $0 == __FILE__
    Gem::manage_gems
    Gem::Builder.new(spec).build
end
