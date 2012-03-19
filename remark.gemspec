Gem::Specification.new do |s|
  s.name    = 'remark'
  s.version = '0.3.1'

  s.add_dependency 'hpricot', '~> 0.8.2'
  s.add_development_dependency 'rspec', '~> 2.9'

  s.summary = "HTML to Markdown converter"
  s.description = "Remark turns simple HTML documents or content in web pages to Markdown source."

  s.authors  = ['Mislav Marohnić']
  s.email    = 'mislav.marohnic@gmail.com'
  s.homepage = 'https://github.com/mislav/remark'

  s.files = Dir['Rakefile', '{bin,lib,rails,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files`.split("\n")
end
