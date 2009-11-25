Gem::Specification.new do |s|
  s.name    = 'remark'
  s.version = '0.3.1'
  s.date    = Date.today.to_s
  
  s.add_dependency 'hpricot', '~> 0.8.2'
  s.add_development_dependency 'rspec', '~> 1.2.9'
  
  s.summary = "HTML to Markdown converter"
  s.description = "Remark turns simple HTML documents or content in web pages to Markdown source."
  
  s.authors  = ['Mislav Marohnić']
  s.email    = 'mislav.marohnic@gmail.com'
  s.homepage = 'http://github.com/mislav/remark'
  
  s.has_rdoc = false
  # s.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  # s.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc']
  
  s.files = Dir['Rakefile', '{bin,lib,rails,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files`.split("\n")
end
