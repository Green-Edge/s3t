require "colorize"
require "spec"
require "../src/runner"
require "tmpdir"

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

  puts "> Starting #{mockservice} with args: #{args.join(" ")}".colorize(:blue)
  mockapi = Process.new(mockservice, args, shell: true)

  puts "> Starting runner...".colorize(:yellow)
  runner = S3t::Runner.new("test.yml")
  result = runner.run()
  puts "> Results: #{result}".colorize(:yellow)

  puts "\n> -- Running checks --".colorize(:dark_gray)
end

Spec.after_suite do
  puts "\n\n> -- Cleaning up --".colorize(:dark_gray)
  puts "> Shutting down #{mockservice}".colorize(:blue)
  mockapi.try &.signal(Signal::KILL)
end
