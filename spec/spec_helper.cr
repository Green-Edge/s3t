require "colorize"
require "log"
require "log/spec"
require "spec"

require "tmpdir"

require "../src/runner"

Log.setup(:none)

mockservice = "s3rver"
mockapi : Process? = nil
port = 4568

Spec.before_suite do
  puts "\n> -- Setting up --".colorize(:dark_gray)
  if !Process.find_executable(mockservice)
    raise "Unable to find #{mockservice} in PATH"
  end

  tmpdir = Dir.mktmpdir("s3t")

  puts "> Created tmpdir: #{tmpdir}".colorize(:blue)

  args = [
    "--directory", tmpdir, # Data directory
    "--port", port.to_s, # Port of the http server (default: 4568)
    "--silent", # Suppress log messages
  ]

  puts "> Starting #{mockservice} on port #{port.to_s}".colorize(:blue)
  mockapi = Process.new(mockservice, args, shell: true)

  Log.capture do |logs|
    puts "> Starting runner...".colorize(:yellow)

    begin

      runner = S3t::Runner.new("spec/test.yml")
      result = runner.run()

      # basic log checks
      logs.check(:debug, /config loaded/i)
      logs.check(:debug, /sample file loaded/i)
      logs.check(:debug, /connecting to: localhost:#{port.to_s}/i)
      logs.check(:info, /starting run/i)
      logs.check(:info, /run completed/i)

      puts "> Results: #{result}".colorize(:yellow)

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
