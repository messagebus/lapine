class AnnotatedLogger < Logger
  attr_accessor :log_method_caller    # if set will log ruby method name substring from where logging is called
  attr_accessor :log_timestamps       # if set will log timestamps up to millisecond
  attr_accessor :colorize_logging     # if set turns on colors (hint: turn off in production)

  NUMBER_TO_COLOR_MAP = {"debug"=>'0;37', "info"=>'32', "warn"=>'33', "error"=>'31', "fatal"=>'31', "unknown"=>'37'}

  def initialize *args
    super *args
    [:info, :debug, :warn, :error, :fatal].each { |m|
      AnnotatedLogger.class_eval %Q!
      def #{m} arg=nil, &block
        level = "#{m}"
        pid = "%.5d:" % $$
        if block_given?
          arg = yield
        end
        out = arg
        out = out.gsub(/\n/, ' ') unless (level == "fatal" || out =~ /\\w+\\.rb:\\d+:in/m)
        t = Time.now
        l = log_message(t, pid, level, out)
        super(l) if l
      end
      !
    }
  end

  def log_message(t, pid, level, out)
    color_on = color_off = sql_color_on = ""
    if self.colorize_logging
      color = NUMBER_TO_COLOR_MAP[level.to_s]
      color_on = "\033[#{color}m"
      sql_color_on = "\033[34m"
      color_off = "\033[0m"
    end
    format_string = ""
    format_values = []
    if self.log_timestamps
      format_string << "%s.%03d "
      format_values << [t.strftime("%Y-%m-%d %H:%M:%S"), t.usec / 1000]
    end
    format_string << "%s #{color_on}%6.6s#{color_off} "
    format_values << [pid, level]

    if self.log_method_caller
      file, line, method = caller_method
      format_string <<  "|%-40.40s "
      format_values << "#{File.basename(file)}:#{line}:#{method}"
    end

    format_string << "%s"
    format_values << [out]
    format_values.flatten!

    format_string % format_values
  end

  def caller_method
    parse_caller(caller(3).first)
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = Regexp.last_match[1]
      line = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      [file, line, method]
    end
  end
end
