require "log"
require "option_parser"

require "./formatters"
require "./runner"

module S3t
  BINARY = "s3t"
  VERSION = "0.1.0"

  configfile = ""
  config : YAML::Any = YAML.parse "{}"
  loglevel = Log::Severity::Info

  parser = OptionParser.parse do |parser|
    parser.banner = "Usage: #{BINARY} [arguments]"
    parser.on("-c FILE", "--config=FILE", "Configuration YAML file") { |file| configfile = file }
    parser.on("-v", "--verbose", "Verbose output") { loglevel = Log::Severity::Debug }
    parser.on("-V", "--very-verbose", "Very verbose output (for debugging)") { loglevel = Log::Severity::Trace }
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  parser.parse

  if configfile == ""
    STDERR.puts parser
    exit(1)
  end

  Log.setup_from_env(
    default_level: loglevel,
    backend: Log::IOBackend.new(formatter: S3t::ColorizedFormatter)
  )

  begin
    runner = Runner.new(configfile)
    runner.run
  rescue ex : Exception
    STDERR.puts ex.to_s
    exit(1)
  end
end
