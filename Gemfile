source 'https://rubygems.org'

#ENV.each_pair {|k,v| puts "#{k}: #{v}"}

# Sinatra
gem 'sinatra'
gem 'sinatra-contrib'
#gem 'thin'
gem 'rake'

gem 'rack-conneg', '~> 0.1.5'
gem 'rack-rest_api_versioning', '~> 0.0.2'

gem 'google-api-client'

#gem 'bundler', '1.10.6'

#gem "foreman", :path => "/Users/pje/my_foreman_fork"
#gem "GGB", :path => "/Users/dlhaines/dev/BITBUCKET/ggb"
#gem "GGB", :path => "/Users/dlhaines/dev/GITHUB/dlh-umich.edu/FORKS/google_groups_gem"

gem 'GGB', :git => "git@github-dlh:dlhaines/google_groups_gem.git", :branch => 'TLPORTAL-309'

#:git => 'https://github.com/rails/rails.git', :ref => '4aded'
#:git => 'https://github.com/rails/rails.git', :branch => '2-3-stable'
#:git => 'https://github.com/rails/rails.git', :tag => 'v2.3.5'

group :development, :test do
  gem 'rack-test'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'webmock'
  # need to require activesupport first ???
  gem 'activesupport', '4.2.5'
  gem 'shoulda'
end

#gem "weakling",   :platforms => :jruby
#gem 'jruby-openssl', '>= 0.9.17' gem "weakling",   :platforms => :jruby
gem 'jruby-openssl', '>= 0.9.17',   :platforms => :jruby

