require "colorize"
require "log"

LOGGER_COLORS = {
  ::Log::Severity::Error  => :red,
  ::Log::Severity::Warn   => :yellow,
  ::Log::Severity::Notice => :light_green,
  ::Log::Severity::Info   => :green,
  ::Log::Severity::Debug  => :dark_gray,
  ::Log::Severity::Trace  => :dark_gray,
}

module S3t
  ColorizedFormatter = ::Log::Formatter.new do |entry, io|
    message = entry.message
    color = LOGGER_COLORS[entry.severity]? || :default
    formatted = message.colorize(color)

    if entry.severity == ::Log::Severity::Trace
      formatted = formatted.mode(:dim)
    end

    io << formatted
  end
end
