require 'rake/testtask'
require 'rake/clean'


VAR_DIR='./var'
CLOBBER.include("#{VAR_DIR}/*")


task :TTD do
  puts <<END_OF_TTD
  GGB_microsevice rake tasks:
 - add tests
 - add docker
 - add build ?
 - make jetty port settable
END_OF_TTD
end
# done
# - convert to run GGB microserver (mri and jruby)
# - check that server is not already running (mri)

# default is to test
task :default => [:TTD, "test"]

#### tasks to run default server
desc "+++ Start and stop test server"
task :server

namespace :server do
  # make sure there is somewhere to put server files.
  directory "#{VAR_DIR}/pids"
  directory "#{VAR_DIR}/log"

  task :directories => ["#{VAR_DIR}/pids", "#{VAR_DIR}/log"]

  desc "Starts mri test version of GGB microservice."

  task :start => [:directories] do

    # forget it if a server is already running.
    if File.exist?("#{VAR_DIR}/pids/thin.pid")
      puts "server already running"
      next
    end
    # default the port to run on.
    ENV['PORT'] = '9100' if ENV['PORT'].nil?
    %x[rackup -s thin -p #{ENV['PORT']} -o '0.0.0.0' --pid #{VAR_DIR}/pids/thin.pid >| #{VAR_DIR}/log/ggb_ms.$$.log 2>&1 &]
    sleep 1
    if File.exist?("#{VAR_DIR}/pids/thin.pid")
      pid = File.open("#{VAR_DIR}/pids/thin.pid", 'rb') { |file| file.read }
      puts "starting server with PID: #{pid} on port #{ENV['PORT']}"
    end
  end

  desc "Stops the mri server started by server:start"
  task :stop do
    puts "Killing server with pid #{%x[cat #{VAR_DIR}/pids/thin.pid]}"
    %x[kill $(cat #{VAR_DIR}/pids/thin.pid)]
  end

  desc "Wait 10 seconds"
  task :wait do
    sleep 10
  end


  desc "Restart the mri server"
  task :restart => [:stop, :wait, :start]

  #Override this by setting the environment variable GGB_CONFIG_FILE.
  desc "Start executible jetty server war Config file will default to ./test/GGB.yml."

  task :war do
    files = Rake::FileList["ARTIFACTS/*war"]
    #GGB_CONFIG_FILE='/Users/dlhaines/dev/GITHUB/dlh-umich.edu/FORKS/google_groups_business/test/GGB.yml'
    GGB_CONFIG_FILE=ENV['GGB_CONFIG_FILE'] || "#{Dir.pwd}/test/GGB.yml"

    puts "running war file: #{files}"
    puts "config file is: #{GGB_CONFIG_FILE}"

    %x[GGB_CONFIG_FILE=#{GGB_CONFIG_FILE} java -jar #{files}]
  end

end

######## Configure tests

# Run all tests if just specify the 'test' task.
desc " Testing tasks"
task :test => ["test:all"]

# define the test tasks
namespace :test do

  task :all => [:all_files]

  Rake::TestTask.new do |t|
    t.libs << "test"
    t.name = "all_files"
    t.description = "test all requests"
    t.test_files = FileList['**/test_*.rb']
    t.verbose = true
    t.ruby_opts += ["-W1"]
  end

end

######################################################
## commands to setup and run vagrant VM with Dashboard
# desc "+++ Commands to setup and run Vagrant VM for Dashboard testing"
# task :vagrant
#
# namespace :vagrant do
#   desc "Make the application build artifacts available for creating the VM"
#   task :get_artifacts do
#     sh "(cd vagrant; ./getArtifacts.sh)"
#   end
#
#   desc "Starts the Vagrant VM, creating it if necessary"
#   task :up => :get_artifacts do
#     sh "(cd vagrant; vagrant up)"
#   end
#
#   desc "Same as the halt task"
#   task :down => :halt
#
#   desc "Stop VM and destroy it"
#   task :destroy do
#     sh "(cd vagrant; vagrant destroy -f)"
#   end
#
#   desc "Halt (stop) the vagrant VM but do not delete it"
#   task :halt do
#     sh "(cd vagrant; vagrant halt)"
#   end
#
#   desc "Open a (debug) xterm to the vagrant VM, YMMV."
#   task :xterm do
#     sh "(cd vagrant; ./vagrantXterm.sh)"
#   end
#
#   desc "Open a ssh terminal connection to the vagrant VM."
#   task :ssh do
#     sh "(cd vagrant; vagrant ssh)"
#   end
#
#   desc "Reload changes into the existing VM.  Avoids redoing initial OS updates."
#   task :reload => :get_artifacts do
#     sh "(cd vagrant; vagrant reload --provision)"
#   end
# end

#end
