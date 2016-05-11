require File.expand_path('../app.rb', __FILE__)

use Rack::Static, :urls => ["/css", "/js"], :root => "public"
use Rack::Static, :urls => {'/' => 'index.html'}, root: 'public'
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end
run API::Version1
#use Rack::Static, :urls => [""], :root => 'public', :index => 'index.html'

