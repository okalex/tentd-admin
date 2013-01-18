lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'pg'
require 'json'

vcap_services = JSON.parse(ENV.fetch('VCAP_SERVICES'))
postgresql = vcap_services['postgresql-9.1']
if service_name = ENV.fetch('DB_SERVICE_NAME', nil)
  service = postgresql.detect{|s| s['name'] == service_name }
else
  service = postgresql.first
end
creds = OpenStruct.new(service['credentials'])
url = ["postgres://"]
url << "#{creds.username}:#{creds.password}"
url << "@#{creds.host}:#{creds.port}"
url << "/#{creds.name}"
ENV['DATABASE_URL'] = url.join('')

require 'tentd'
require 'tentd-admin/app'
require 'tentd-admin/setup_tent'
require 'tentd-admin/set_entity'
require 'rack/ssl-enforcer'
require 'logger'

DB = Sequel.connect ENV['DATABASE_URL']
Sequel.extension :migrations
Sequel::Migrator.apply(DB, './db/migrations')

use Rack::SslEnforcer, hsts: true if ENV['RACK_ENV'] == 'production'

map (ENV['TENT_SUBDIR'] || '') + '/' do
  use SetEntity
  run TentD.new
end

map (ENV['TENT_SUBDIR'] || '') + '/oauth' do
  run lambda { |env|
    auth_url = ((env['HTTP_X_FORWARDED_PROTO'] || env['rack.url_scheme']) + '://' + env['HTTP_HOST'])
    auth_url += (ENV['TENT_SUBDIR'] || '')
    auth_url += '/admin/oauth/confirm'
    auth_url += "?#{env['QUERY_STRING']}"
    [301, { "Location" => auth_url }, []] }
end

map (ENV['TENT_SUBDIR'] || '') + '/admin' do
  use Rack::Session::Cookie,  :key => 'tent.session',
                              :expire_after => 2592000, # 1 month
                              :secret => ENV['COOKIE_SECRET'] || SecureRandom.hex
  use(Rack::Auth::Basic, 'Tent Admin') { |u,p| u == ENV['ADMIN_USERNAME'] && p == ENV['ADMIN_PASSWORD'] }
  use SetupTent
  run TentD::Admin
end
