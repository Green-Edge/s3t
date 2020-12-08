require "log"
require "option_parser"
require "./runner"

module S3t
  BINARY = "s3t"
  VERSION = "0.1.0"

  configfile = ""
  config : YAML::Any = YAML.parse "{}"

  parser = OptionParser.parse do |parser|
    parser.banner = "Usage: #{BINARY} [arguments]"
    parser.on("-c FILE", "--config=FILE", "Configuration YAML file") { |file| configfile = file }
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

  Log.setup_from_env(default_level: :info)

  runner = Runner.new(configfile)
  runner.run
end
