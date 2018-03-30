source "https://rubygems.org"

# Specify your gem's dependencies in join_dependency.gemspec
gemspec

case ENV.fetch('AR', 'latest')
when 'latest'
  gem 'activerecord'
when 'master'
  gem 'activerecord', github: 'https://github.com/rails/rails'
else
  gem 'activerecord', ENV['AR']
end

