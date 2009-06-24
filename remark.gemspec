# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{remark}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mislav Marohni\304\207"]
  s.date = %q{2009-06-24}
  s.default_executable = %q{remark}
  s.email = %q{mislav.marohnic@gmail.com}
  s.executables = ["remark"]
  s.files = ["Rakefile", "bin/remark", "lib/remark.rb", "spec/remark_spec.rb", "spec/sample.html", "README.markdown"]
  s.homepage = %q{http://github.com/mislav/remark}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{HTML to Markdown converter}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
