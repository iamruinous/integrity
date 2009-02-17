#!/usr/bin/env ruby
require "rubygems"
# since we are deploying integrity as a webapp instead of a gem, force the lib
# subdirectory into the path
$: << File.join( File.expand_path( File.dirname( __FILE__ ) ), "lib" )

require "integrity"
require "notifier/email"

# If you want to add any notifiers, install the gems and then require them here
# For example, to enable the Email notifier: install the gem (from github:
#
#   sudo gem install -s http://gems.github.com foca-integrity-email
#
# And then uncomment the following line:
#
# require "notifier/email"

# Load integrity's configuration.
Integrity.config = File.expand_path("./config.yml")

#######################################################################
##                                                                   ##
## == DON'T EDIT ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING == ##
##                                                                   ##
#######################################################################
require Integrity.root / "app"

set     :environment, ENV["RACK_ENV"] || :production
set     :public,      Integrity.root / "public"
set     :views,       Integrity.root / "views"
set     :port,        8910
disable :run, :reload

use Rack::CommonLogger, Integrity.logger if Integrity.config[:log_debug_info]
run Sinatra::Application
