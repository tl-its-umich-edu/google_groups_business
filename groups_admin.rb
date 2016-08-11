# Encoding: utf-8
require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'json'
require 'logging'

require 'ggb'

require 'sinatra/respond_with'
#require 'sinatra/contrib/all'

# avoids the tilt autoloading message.
require 'tilt/erb'

require 'rack/conneg'
require "sinatra/reloader" if development?

#require 'google/apis/admin_directory_v1'


### TTD (not in order of importance)
# api versioning
# config / yml
# html escape
# content negotiation
## value is returned in json except status is json and html
# groups/<group id> (PUT GET DELETE)
# groups/<group id>/members (PUT POST GET DELETE)
# groups/<group name>/messages (POST)
# change json templates to all use hash template
# timing of calls

### TTD DONE
# status (GET)
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


# Add logger that can be overridden.  Sample call below.
#GGBServiceAccount.logger.debug "initalized"


# probably want api versioning
#require 'rack/rest_api_versioning' don't want this as it uses accept or mime only

# generate list of possible yml config file names.
def get_possible_config_file_names(file_name_prefix='default')
  names = []
  # give priority to environment setting.
  names << ENV['GGB_CONFIG_FILE'] unless ENV['GGB_CONFIG_FILE'].nil?
  # add standard locations.
  names.concat ["/usr/local/ctools/app/ctools/tl/home/#{file_name_prefix}.yml", "./#{file_name_prefix}.yml", './default.yml']
end

def verify_file_is_usable(requested_file)
  ((File.exists? requested_file) && File.readable?(requested_file)) ? requested_file : nil
end

# return name of first file in the list that is readable, otherwise log and return nil.
def get_readable_config_file_name(candidate_files)
  none_found = lambda {
    # TODO: replace with logger.
    puts "FATAL: #{self.class.to_s}:#{__method__}:#{__LINE__}: cannot readable configuration file: in [#{candidate_files}]"
    nil
  }
  candidate_files.detect(none_found) { |f| verify_file_is_usable(f) }
end

## This must be after any methods it uses.
configure do
  config_file = get_readable_config_file_name(get_possible_config_file_names('GGB'))
  ## TODO: replace with logger
  puts "use config_file: [#{config_file}]"
  set :config_file, config_file
end

helpers do
  def status_data
    {
        :current_time => Time.now.iso8601,
        :server => Socket.gethostname,
        :ping => to("/status/ping.json")
    }
  end

  def update_accept_header(extension, mime_type)
    if request.url.match(/.#{extension}$/)
      request.accept.unshift(mime_type)
      request.path_info = request.path_info.gsub(/.#{extension}$/, '')
    end
  end

  # Run a specific request
  def run_request(config, use_args)

    s = GGBServiceAccount.new()
    s.configure(settings.config_file, config[:service_name])

    # run the method
    begin
      result = s.send(config[:method_symbol], *use_args)
    rescue GGBServiceAccountError => ggb_err
      raise ggb_err
    rescue => exp
      # just pass exceptions back
      halt exp.status_code, exp.message
    end

    # handle any successful results
    config[:handle_result].(result)
  end

end
# set accept header, and reset if have known extension
before /.*/ do
  # default to json
  request.accept.unshift('application/json')
  # set based on extension.
  update_accept_header 'json', 'application/json'
  update_accept_header 'html', 'text/html'
end


############## status urls
# basic static status, ping
get '/status', :provides => [:json, :html] do
  respond_to do |format|
    # setup the data
    @data = status_data
    # invoke proper template
    format.json { erb :'status.json' }
    format.html { erb :'status.html' }
  end
end


#get '/status/ping.?:format?' do |format|

get '/status/ping', :provides => [:json, :html] do
  #format = 'html' unless (format)
  respond_to do |format|
    @data = {:ping => 'ok'}
    # invoke proper template
    format.json { erb :'hash.json' }
    format.html { erb :'status_ping.html' }
  end
end

## value is returned in json except status can return either json or html
# groups/<group id> (PUT GET DELETE)

################ groups ###############
# create group representations
# input:  https://developers.google.com/admin-sdk/directory/v1/guides/manage-groups
# output: https://developers.google.com/admin-sdk/directory/v1/reference/groups#resource

# list groups
## Return list of ids or list of array/hash [id,url]
## put / post must accept (optional) settings

get '/groups/?', :provides => [:json, :html] do
  respond_to do |format|
    config = {
        :args => nil,
        :method_symbol => :list_groups,
        :handle_result => Proc.new { |result| result },
        :service_name => 'ADMIN_DIRECTORY'
    }

    # get the data
    @data = run_request(config, [])
    # format as required
    format.json { erb :'groups.json' }
    format.html { erb :'groups.json' }
  end
end

# Expects the body of the put to contain group email, group name and description.
# If the gid and the email don't agree then
put '/groups/:gid' do |gid|
  # assumes that request has not already been read
  body = request.body.read
  #verify that the email is not in the body (and add) or is the same.

  config = {
      :args => nil,
      :method_symbol => :insert_new_group,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }

  params2 = {:email => params['email'],
             :name => params['name'],
             :description => params['description']}

  unless gid == params[:email]
    halt 422, "requested id is inconsistent"
  end

  # put argument in array so it isn't treated as a hash of keyword parameters.
  #run_request(config, [params2])

  begin
    run_request(config, [params2])
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end

end

post '/groups/:gid' do |gid|
  halt 501,"not implemented"
end

# get specific group information
get '/groups/:gid' do |gid|

  config = {
      :args => gid,
      :method_symbol => :get_group_info,
      :handle_result => Proc.new { |result|
        halt 404, "group not found" unless result
        result.to_json
      },
      :service_name => 'ADMIN_DIRECTORY'
  }

  begin
    run_request(config, gid)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end

end

# delete a group
delete '/groups/:gid' do |gid|
  config = {
      :args => gid,
      :method_symbol => :delete_group,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }

  begin
    run_request(config, gid)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end

end

############## group members
# groups/<group id>/members (PUT POST GET DELETE)

get '/groups/:gid/members' do |gid|
  config = {
      :args => gid,
      :method_symbol => :list_members,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }
  begin
    run_request(config, gid)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end
end

get '/groups/:gid/members/:uid' do |gid, uid|
  config = {
      :args => [gid, uid],
      :method_symbol => :get_member,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }
  begin
    run_request(config, [gid, uid])
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end
end

put '/groups/:gid/members/:uid' do |gid, uid|
  role = params[:role] ? params[:role] : 'MEMBER'
  halt 400, "invalid member role: [#{role}]" unless ['MEMBER', 'OWNER'].include? role

  config = {
      :args => [gid, uid],
      :method_symbol => :insert_member,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }

  use_args = [gid, {'email': uid, 'role': role}]

  begin
    run_request(config, use_args)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end
end

#def delete_member group_key, member_key
delete '/groups/:gid/members/:uid' do |gid, uid|
  config = {
      :args => [gid, uid],
      :method_symbol => :delete_member,
      :handle_result => Proc.new { |result| result },
      :service_name => 'ADMIN_DIRECTORY'
  }

  use_args = [gid, uid]

  begin
    run_request(config, use_args)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end
end

post '/groups/:gid/members' do |gid|
  halt 501, "not sensible"
end

######### group email archive
## NOTE: there is currently no API to get messages from
## a group, only to add messages to a group.


# config = {
#     :args => args,
#     :required_args => 3,
#     :method_symbol => :insert_archive,
#     :handle_result => Proc.new { |result|
#       puts "#{__method__}: group: #{args[1]} email: #{args[2]}"
#       puts "#{__method__}: result: #{result.inspect}"
#     },
#     :service_name => 'GROUPS_MIGRATION'
# }
#
# email = get_email_from_file args[2]
# use_args = [args[1], email]
#
# run_request(config, use_args)

post '/groups/:gid/messages' do |gid|
  request_body = request.body.read
  puts "request body: #{request_body}"

  config = {
      :args => [gid, request_body],
      :method_symbol => :insert_archive,
      :handle_result => Proc.new { |result| result },
      :service_name => 'GROUPS_MIGRATION'
  }

  use_args = [gid, request_body]

  begin
    run_request(config, use_args)
  rescue GGBServiceAccountError => ggb_err
    halt ggb_err.status_code, ggb_err.cause.to_json
  end

end

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

@@ groups.json
 <%= @data %>

@@ hash.json
 <%= @data.to_json %>

@@ status_ping.html
<!DOCTYPE html>
<html>
<body>
<div style="margin-left:20px;">
<%= "#{@data[:ping]}" %>
</div>
</body>
</html>
