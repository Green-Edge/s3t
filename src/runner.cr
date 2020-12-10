require "log"
require "uuid"

require "awscr-s3"
require "fiberpool"

require "./config"
require "./dir"


module S3t

  class Runner
    Log = ::Log.for(self)

    @config : Config
    @filedata : IO::Memory
    @dir : S3t::Dir

    def initialize(configfile : String)
      @configfile = configfile
      @config = load_config()
      @filedata = load_file()

      @dir = Dir.new(@config.limits.per_dir)
    end

    def load_config
      begin
        config = File.open(@configfile) do |file|
          Config.from_yaml(file)
        end
      rescue File::NotFoundError
        raise("cannot read file: #{@configfile}")
      rescue ex : YAML::ParseException
        raise("#{@configfile} contains invalid YAML: #{ex}")
      end

      Log.debug {"Config loaded from #{@configfile}"}

      return config
    end

    def load_file
      contents = File.open(@config.storage.upload) do |file|
        file.gets_to_end
      end

      mem = IO::Memory.new(contents)

      sleep 15

      Log.debug {"Sample file loaded from #{@config.storage.upload} (#{mem.size})"}

      return mem
    end

    def new_client
      Log.debug {"Creating new connection to: #{@config.service.endpoint}"}
      Awscr::S3::Client.new(
        "target",
        @config.service.keys.access,
        @config.service.keys.secret,
        endpoint: @config.service.endpoint,
      )
    end

    def ensure_bucket
      client = new_client()
      bucket = @config.storage.bucket

      begin
        client.head_bucket(bucket)
      rescue ex : Exception
        client.put_bucket(bucket)
      end

      Log.debug {"Using bucket: #{bucket}"}
    end

    def run
      ensure_bucket()

      Log.info {"Starting run"}
      Log.debug {"  concurrency is: #{@config.limits.concurrency}"}

      results = [] of Bool

      pool = Fiberpool.new(
        1..@config.limits.count,
        @config.limits.concurrency
      )

      pool.run do |item|
        # @config.limits.count.times do
        filepath = "#{@dir.get}/#{UUID.random.to_s}.png"
        results << upload(filepath)
      end

      Log.info {"Run completed"}
      return results
    end

    def upload(filepath)

      Log.debug {"Uploading to: #{filepath} (#{@filedata.size})"}

      client = new_client()
      uploader = Awscr::S3::FileUploader.new(client)

      result = uploader.upload(
        @config.storage.bucket,
        filepath,
        @filedata
      )

      return result
    rescue ex : Awscr::S3::Exception
      Log.error {"Upload failed: #{filepath}"}
      return false
    end
  end

end
