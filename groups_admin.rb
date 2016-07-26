# Encoding: utf-8
require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'json'

#require 'sinatra/respond_with'
#require 'sinatra/contrib/all'

# avoids the tilt autoloading message.
require 'tilt/erb'

require 'rack/conneg'
#require "sinatra/reloader" if development?


### TTD (not in order of importance)
# api versioning
# config / yml
# html escape
# auto reload
# content negotiation
## value is returned in json except status is json and html
# groups/<group id> (PUT GET DELETE)
# groups/<group id>/members (PUT POST GET DELETE)
# groups/<group name>/messages (POST)
# status (GET)
# empty

### TTD DONE
# auto reload
# automatical templates based on the extension (pattern is known)
# may want
# sinatra/config_file
#sinatra/json
#sinatra/link_header
# With Sinatra::RespondWith
# get '/' do
#   respond_with :index, :name => 'example' do |f|
#     f.txt { 'just an example' }
#   end
# end
# get '/posts' do
#   @posts = Post.recent
#
#   respond_to do |wants|
#     wants.html { haml :posts }      # => views/posts.html.haml, also sets content_type to text/html
#     wants.rss { haml :posts }       # => views/posts.rss.haml, also sets content_type to application/rss+xml
#     wants.atom { haml :posts }      # => views/posts.atom.haml, also sets content_type to appliation/atom+xml
#   end
# end
# get '/projects', :provides => [:html, :json] do
#   @projects = Project.projects
#   respond_to do |format|
#     format.json { @projects.to_json }
#     format.html { erb :index }
#   end
# end


# probably want api versioning
#require 'rack/rest_api_versioning' don't want this as it uses accept or mime only

helpers do
  def status_data
    {:current_time => Time.now.iso8601}
  end
end

def update_accept_header(extension,mime_type)
  if request.url.match(/.#{extension}$/)
    request.accept.unshift(mime_type)
    request.path_info = request.path_info.gsub(/.#{extension}$/, '')
  end
end

# set accept header, and reset if have known extension
before /.*/ do
  # default to json
  request.accept.unshift('application/json')
  # set based on extension.
  update_accept_header 'json','application/json'
  update_accept_header 'html','text/html'
end

get '/status', :provides => [:json, :html] do
  respond_to do |format|
    # setup the data
    @data = status_data
    # invoke proper template
    format.json { erb :'status.json' }
    format.html { erb :'status.html' }
  end
end

## value is returned in json except status can return either json or html
# groups/<group id> (PUT GET DELETE)

################ groups ###############


# list groups
## Return list of ids or list of array/hash [id,url]
## put / post must accept (optional) settings
get '/groups' do
  "get all groups via group email"
end

# create new group / update existing group
## must accept settings values
put '/groups/:gid' do |gid|
  "create a group: #{gid}"
end

# get specific group information
get '/groups/:gid' do |gid|
  "get one group settings: [#{gid}]"
end

# delete a group
## deal with members? / do not return existing information
delete '/groups/:gid' do |gid|
  "delete group: #{gid}"
end

############## group members
# groups/<group id>/members (PUT POST GET DELETE)
############## group messages
# groups/<group name>/messages (POST)
####################

# require 'mongoid'
# require 'roar/json/hal'
# require 'rack/conneg'
#
# configure do
#   Mongoid.load!("config/mongoid.yml", settings.environment)
#   set :server, :puma # default to puma for performance
# end
#
# use(Rack::Conneg) { |conneg|
#   conneg.set :accept_all_extensions, false
#   conneg.set :fallback, :json
#   conneg.provide([:json])
# }
#
# before do
#   if negotiated?
#     content_type negotiated_type
#   end
# end
#
# class Product
#   include Mongoid::Document
#   include Mongoid::Timestamps
#
#   field :name, type: String
# end
#
# module ProductRepresenter
#   include Roar::JSON::HAL
#
#   property :name
#   property :created_at, :writeable=>false
#
#   link :self do
#     "/products/#{id}"
#   end
# end
#
# get '/products/?' do
#   products = Product.all.order_by(:created_at => 'desc')
#   ProductRepresenter.for_collection.prepare(products).to_json
# end
#
# post '/products/?' do
#   name = params[:name]
#
#   if name.nil? or name.empty?
#     halt 400, {:message=>"name field cannot be empty"}.to_json
#   end
#
#   product = Product.new(:name=>name)
#   if product.save
#     [201, product.extend(ProductRepresenter).to_json]
#   else
#     [500, {:message=>"Failed to save product"}.to_json]
#   end
# end

#    <% @information['urls'].each_value {|url| url.gsub!(/EXT$/,'json')}%>
#    <%= @information.to_json %>

#################################################################

## Include templates inline.
__END__
@@ status.json
 <%= @data.to_json %>

@@ status.html
<!DOCTYPE html>
<html>
<body>

data:
<div style="margin-left:20px;">
  <table>
    <% @data.each do |k, v| %>
        <tr>
          <td><%= "<em>#{k}</em>: #{v}" %></td>
        </tr>
    <% end %>
  </table>
</div>

</body>
</html>

