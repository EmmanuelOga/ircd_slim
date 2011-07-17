# Used on development mode.
# $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../../irc_parser/lib"))

require 'irc_parser'

require 'logger'
require 'socket'
require 'forwardable'

require 'ansi'
require 'irc_parser'
require 'eventmachine'

require 'ircd_slim/extensions/blank' unless nil.respond_to?(:blank?)

module IRCDSlim
  VERSION = "0.0.1"

  autoload :Channel , "ircd_slim/channel"
  autoload :Client  , "ircd_slim/client"
  autoload :Message , "ircd_slim/message"
  autoload :Server  , "ircd_slim/server"

  module Protocol
    autoload :Channel , 'ircd_slim/protocol/channel'
    autoload :Client  , 'ircd_slim/protocol/client'
    autoload :Server  , 'ircd_slim/protocol/server'
  end

  module Network
    autoload :Client     , "ircd_slim/network/client"
    autoload :Connection , "ircd_slim/network/connection"
    autoload :Listener   , "ircd_slim/network/listener"
  end
end
