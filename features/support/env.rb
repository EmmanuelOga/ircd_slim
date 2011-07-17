require 'ircd_slim'
require 'forwardable'

module Helpers
  def self.run_ircd
    pid = fork do
      require 'ircd_slim/support/basic_server'
    end

    at_exit do
      Process.kill("INT", pid)
    end

    sleep 1
  end

  def clients
    @clients ||= Hash.new { |h,k| h[k] = IRCClient.new(k) }
  end

  def parse_value(val)
    case val
    when nil then nil
    when /\$(.*)$/ then $VARS[$1]
    when /^\/(.*)\/$/ then /#{$1}/
    else
      val
    end
  end
end

World(Helpers)

$ircd_port = 10000
$hostname = `hostname`.chomp

$VARS = Hash.new { |h, k| h[k] = eval(k) }
$VARS["server_host"] = $hostname

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

$run_ircd_process = true

Helpers.run_ircd if $run_ircd_process
