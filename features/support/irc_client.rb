require 'socket'
require 'logger'
require 'irc_parser'

# set_trace_func proc { |event, file, line, id, binding, classname|
   # printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
# }

class IRCClient
  attr_reader :logger, :name

  def initialize(name, port = $ircd_port)
    @name = name
    @socket = TCPSocket.new("127.0.0.1", port)
    @logger = Logger.new(File.join(File.dirname(__FILE__), "..", "..", "log", "irc_client.log"))

    logger.info("-" * 80)
    logger.info("#{name} - Starting Client #{Time.now}")
    logger.info("-" * 80)
  end

  def stop
    logger.info("#{name} - Stopping")
    @socket.close if @socket && !@socket.closed?
  end

  def send_data(data)
    logger.debug("\n#{name} - SENDING:\n#{data}")
    @socket.write(data)
    @socket.flush; sleep(0.01) # this helps avoiding buffer problems.
  end

  def send_raw(string)
    send_data("#{string}\r\n")
  end

  def message(msg, &block)
    send_data(IRCParser.message(msg, &block))
  end

  RETRIES_LIMIT = 2

  def receive
    result, retries = "", 1

    loop do
      readable = IO.select([@socket], nil, nil, 0.01)

      if readable && readable.first
        line = @socket.gets
        if line
          result << line
        else
          retries += 1
        end
      else
        retries += 1
      end

      # Uncomment " && $run_ircd_process" to enable debugging:
      # If the ircd process was started from command line to debug,
      # this will avoid breaking the loop and will wait forever,
      # so the client does not desconnect while debugging
      break if retries > RETRIES_LIMIT # && !$run_ircd_process
    end

    logger.debug("\n#{name} - RECEIVING:\n#{result}")

    result
  end

  def receive_messages!
    @received_messages ||= []

    receive.split("\r\n").map do |message|
      @received_messages << IRCParser.parse("#{message}\r\n")
    end

    @received_messages
  end

  def never_received?
    @received_messages.nil?
  end

  def received_messages(select = nil, pump = false)
    receive_messages! if pump || never_received?

    if select
      klass = IRCParser.message_class(select)
      @received_messages.select { |msg| klass === msg }
    else
      @received_messages
    end
  end

  def number_of_received_messages
    @received_messages.respond_to?(:length) ? @received_messages.length : 0
  end
end
