# Encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'logging'

require 'sinatra/respond_with'
#require 'sinatra/contrib/all'

# avoids the tilt autoloading message.
require 'tilt/erb'

require 'rack/conneg'
require "sinatra/reloader" if development?

require_relative './stopwatch'

### TTD (not in order of importance)
# api versioning
# config / yml
# html escape

#### setting environment by hand for the moment.
#set :environment, :production
#set :environment, :development
set :environment, :test

puts "environment: #{settings.environment}"

enable :logging

# Setup logger.  May want to have setup in config.ru
## Sometimes use puts if logger is not available.
new_logger = Logger.new($stdout)
new_logger.level = Logger::ERROR
set :shared_logger, new_logger

configure :production do
  set :logger_level, Logger::INFO
  puts "with production settings"
end

configure :test do
  set :logger_level, Logger::ERROR
end

configure :development do
  set :logger_level, Logger::DEBUG
  puts "with development settings"
end

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

def configure_ggb_service(config_file)
  msg = "#{self.class.to_s}:#{__method__}:#{__LINE__}: config file: #{config_file}"
  puts "configure_ggb_service: #{msg}"
  #settings.shared_logger.error(msg)
  cf_load = YAML.load_file(config_file)
  ggb_service = [cf_load['CREDENTIALS']['SERVICE_USER'], cf_load['CREDENTIALS']['SERVICE_PASSWORD']]
  ggb_service
end

## This must be after any methods that is uses.
configure do

  config_file = get_readable_config_file_name(get_possible_config_file_names('GGB'))
  ## TODO: replace with logger
  msg = "configure: use config_file: [#{config_file}]"
  puts msg
  set :config_file, config_file
  set :ggb_service, configure_ggb_service(config_file)

end

# Basic auth authentication helpers based on Sinatra FAQ
helpers do
  def protected!
    return if authorized?
    # If not authorized then return a challenge.
    headers['WWW-Authenticate'] = 'Basic realm="GGB Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    # check if the user and pw match
    ggb_service_creds = settings.ggb_service
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ggb_service_creds[0], ggb_service_creds[1]]
  end
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
    logger.debug "#{self.class.to_s}:#{__method__}:#{__LINE__}: run_request: config: #{config.inspect} use_args: #{use_args.inspect}"

    # Setup passing the logger to GGB
    s = GGBServiceAccount.new()
    s.configure(settings.config_file, config[:service_name])
    t = settings.shared_logger
    t.level = settings.logger_level
    GGBServiceAccount.logger = t

    # run the method
    begin
      startTime = Time.now
      result = s.send(config[:method_symbol], *use_args)
    rescue GGBServiceAccountError => ggb_err
      raise ggb_err
    rescue => exp
      # just pass exceptions back
      logger.error "#{self.class.to_s}:#{__method__}:#{__LINE__}: run_request: exception: #{exp.inspect}"
      halt exp.status_code, exp.message
    ensure
      endTime = Time.now
      msg = "elapsed time: #{endTime-startTime}: request: #{use_args.inspect}"
      logger.debug "#{self.class.to_s}:#{__method__}:#{__LINE__}: #{msg}"
    end

    # handle any successful results
    config[:handle_result].(result)
  end

end


##################### routes and processing

# make the logger available for requests
before { env['rack.logger'] = settings.shared_logger }

############ stopwatch #################
### Set up single stopwatch for a single request.
## may need to do non-cookie session.  See http://www.sinatrarb.com/intro.html#Using%20Sessions

## setup stopwatch filters so each request is timed
before "*" do
  # Start a request timer.
  msg = Thread.current.to_s + "\t#{request.request_method}\t#{request.url.to_s}"
  sd = Stopwatch.new(msg)
  sd.start

  # Store a stack of stopwatches in case there are recursive calls.
  session[:thread] = Array.new if session[:thread].nil?
  session[:thread].push(sd)
end

### end and print the stopwatch
after "*" do
  unless session[:thread].nil?
    request_sd = session[:thread].pop
  end
  ## if redirect from self then the stopwatch doesn't get setup so have no information.
  if request_sd.nil?
    logger.info "#{self.class.to_s}:#{__method__}:#{__LINE__}: after: stopwatch: nil"
  end

  unless request_sd.nil?
    request_sd.stop
    logger.info "#{self.class.to_s}:#{__method__}:#{__LINE__}: after: status: #{response.status} stopwatch: #{request_sd.pretty_summary}"
  end
  response
end


############ authentication routes ##################
# assume requests require authentication
before do
  @protected = true
end

# Exempt some urls from protection
["/status*", "/status/*", "/test/unprotected"].each do |path|
  before path do
    @protected = false
  end
end

# now check protection for every request
before do
  protected! if (@protected)
end
######## end of authentication route matching. ###############

############## setup content types ####################
# setup acceptable content types
before do
  # default to json
  request.accept.unshift('application/json')
  # set based on extension.
  update_accept_header 'json', 'application/json'
  update_accept_header 'html', 'text/html'
end

######### URL space for testing authentication ############
#######################
get '/test/protected' do
  "Welcome, authenticated!"
end

get '/test/unprotected' do
  "Welcome, ignoring authentication!"
end
#########################

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

get '/status/ping', :provides => [:json, :html] do
  respond_to do |format|
    @data = {:ping => 'ok'}
    # invoke proper template
    format.json { erb :'hash.json' }
    format.html { erb :'status_ping.html' }
  end
end
##############

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
  halt 501, "not implemented"
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

post '/groups/:gid/messages' do |gid|
  request_body = request.body.read

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
