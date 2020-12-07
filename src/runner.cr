require "log"
require "fiberpool"
require "awscr-s3"
require "./config"

module S3t

  class Runner
    Log = ::Log.for(self)

    @config : Config
    @filedata : String

    def initialize(configfile : String)
      @configfile = configfile
      @config = load_config()
      @filedata = load_file()
    end

    def load_config
      begin
        config = File.open(@configfile) do |file|
          Config.from_yaml(file)
        end
      rescue File::NotFoundError
        Log.error { "cannot read file: #{@configfile}" }
        exit(1)
      rescue ex : YAML::ParseException
        raise("#{@configfile} contains invalid YAML: #{ex}")
      end

      Log.debug {"Config loaded from #{@configfile}"}

      return config
    end

    def load_file
      begin
        contents = File.read(@config.storage.upload)
      end

      Log.debug {"File loaded from #{@config.storage.upload} (#{contents.size})"}

      return contents
    end

    def run
      Log.info {"Starting run, concurrency is: #{@config.limits.concurrency}"}

      queue = (1..@config.limits.count).to_a
      results = [] of Int32

      pool = Fiberpool.new(queue, @config.limits.concurrency)
      pool.run do |item|
        results << item
      end
    end
  end

end
