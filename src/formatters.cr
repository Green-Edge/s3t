require "colorize"
require "log"

LOGGER_COLORS = {
  ::Log::Severity::Error => :red,
  ::Log::Severity::Warn  => :yellow,
  ::Log::Severity::Info  => :green,
  ::Log::Severity::Debug => :dark_gray,
}

module S3t
  ColorizedFormatter = ::Log::Formatter.new do |entry, io|
    message = entry.message
    color = LOGGER_COLORS[entry.severity]? || :default
    io << message.colorize(color)
  end
end
