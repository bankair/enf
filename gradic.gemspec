# encoding: utf-8
#
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'gradic/version'
Gem::Specification.new do |s|
  s.name = 'gradic'
  s.version = Gradic::Version::STRING
  s.summary = 'Fast and memory lightweight white/black list implementation'
  s.description = 'Graph based white/black list implementation'
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
  s.license = 'MIT'
end
