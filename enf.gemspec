# encoding: utf-8
#
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'enf/version'
Gem::Specification.new do |s|
  s.name = 'enf'
  s.version = Enf::Version::STRING
  s.summary = 'Elephants never forget'
  s.description = 'Graph based white/black list implementation. Your elephant won\'t forget.'
  s.authors = ['Alexandre Ignjatovic']
  s.email = 'alexandre.ignjatovic@gmail.com'
  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    spec/.*
    |.*\.swp
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    )$}x
  end
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/bankair/enf'
  s.license = 'MIT'
end
