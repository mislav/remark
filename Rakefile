desc "renders the spec/sample.html to Markdown"
task :sample do
  system %(ruby -Ilib -rubygems bin/remark spec/sample.html)
end

desc "generates .gemspec file"
task :gemspec do
  spec = Gem::Specification.new do |gem|
    gem.name = "remark"
    gem.version = '0.3.0'
    
    gem.summary = "HTML to Markdown converter"
    gem.email = "mislav.marohnic@gmail.com"
    gem.homepage = "http://github.com/mislav/remark"
    gem.authors = ["Mislav Marohnić"]
    gem.has_rdoc = false
    
    gem.files = FileList['Rakefile', '{bin,lib,rails,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files`.split("\n")
    gem.executables = Dir['bin/*'].map { |f| File.basename(f) }
  end
  
  spec_string = spec.to_ruby
  
  begin
    Thread.new { eval("$SAFE = 3\n#{spec_string}", binding) }.join 
  rescue
    abort "unsafe gemspec: #{$!}"
  else
    File.open("#{spec.name}.gemspec", 'w') { |file| file.write spec_string }
  end
end
