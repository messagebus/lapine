module Lapine
  class CLI
    attr_reader :argv, :command

    def initialize(argv)
      @argv = argv
      @command = argv.shift
    end

    def run
      case command
      when 'consume'
        require 'lapine/consumer'
        ::Lapine::Consumer::Runner.new(argv).run
      else
        usage
      end
    end

    def usage
      puts <<-EOF.gsub(/^ {8}/, '')
        Usage: lapine [command] [options]

          commands: consume
      EOF
      exit 1
    end

  end
end
