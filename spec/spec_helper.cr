require "colorize"
require "log"
require "log/spec"
require "spec"

require "tmpdir"

require "../src/runner"

Log.setup(:none)

mockservice = "s3rver"
mockapi : Process? = nil
address = "0.0.0.0"
port = 4568

results = [] of Bool
logs : Log::EntriesChecker
config = nil

describe S3t do

  Spec.before_suite do
    puts "\n> -- Setting up --".colorize(:dark_gray)
    if !Process.find_executable(mockservice)
      raise "Unable to find #{mockservice} in PATH"
    end

    tmpdir = Dir.mktmpdir("s3t")

    puts "> Created tmpdir: #{tmpdir}".colorize(:blue)

    args = [
      "--directory", tmpdir, # Data directory
      "--address", address, # Hostname or IP to bind to (default: "localhost")
      "--port", port.to_s, # Port of the http server (default: 4568)
      "--silent", # Suppress log messages
    ]

    puts "> Starting #{mockservice} with: #{args.to_s}".colorize(:blue)
    mockapi = Process.new(mockservice, args, shell: true)
    sleep 3

    Log.capture do |log_output|
      puts "> Starting runner...".colorize(:yellow)

      begin

        runner = S3t::Runner.new("spec/test.yml")
        config = runner.config

        results = runner.run()
        logs = log_output

        # puts "> Results: #{results}".colorize(:yellow)

      rescue ex : Exception
        puts "> Exception encountered: #{ex}".colorize(:red)
        Spec.finish_run  # bail early
      end
    end

    puts "\n> -- Running checks --".colorize(:dark_gray)
  end

  Spec.after_suite do
    puts "\n\n> -- Cleaning up --".colorize(:dark_gray)
    puts "> Shutting down #{mockservice}".colorize(:blue)
    mockapi.try &.signal(Signal::KILL)
  end

end
