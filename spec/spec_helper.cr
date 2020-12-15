require "colorize"
require "log"
require "log/spec"
require "spec"

require "tmpdir"

require "../src/runner"

Log.setup(:none)

module Store
  class_property! results : Array(Bool)
  class_property! logs : Log::EntriesChecker
  class_property! config : S3t::Config

  class_property address = "0.0.0.0"
  class_property port = 4568
end

describe S3t do

  mockservice = "s3rver"
  mockapi : Process? = nil

  Spec.before_suite do
    puts "\n> -- Setting up --".colorize(:dark_gray)

    if !Process.find_executable(mockservice)
      raise "Unable to find #{mockservice} in PATH"
    end

    tmpdir = Dir.mktmpdir("s3t")

    puts "> Created tmpdir: #{tmpdir}".colorize(:blue)

    args = [
      "--directory", tmpdir, # Data directory
      "--address", Store.address, # Hostname or IP to bind to (default: "localhost")
      "--port", Store.port.to_s, # Port of the http server (default: 4568)
      "--silent", # Suppress log messages
    ]

    puts "> Starting #{mockservice} with: #{args.to_s}".colorize(:blue)
    mockapi = Process.new(mockservice, args, shell: true)
    sleep 3

    Log.capture do |logs|
      puts "> Starting runner...".colorize(:yellow)

      runner = S3t::Runner.new("spec/test.yml")

      Store.config = runner.config
      Store.results = runner.run()
      Store.logs = logs

    rescue ex : Exception
      puts "> Exception encountered: #{ex}".colorize(:red)
      Spec.finish_run  # bail early
    end

    puts "\n> -- Running checks --".colorize(:dark_gray)
  end

  Spec.after_suite do
    puts "\n\n> -- Cleaning up --".colorize(:dark_gray)
    puts "> Shutting down #{mockservice}".colorize(:blue)
    mockapi.try &.signal(Signal::KILL)
  end

end
