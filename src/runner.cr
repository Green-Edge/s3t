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
    @filedata : String
    @dir : S3t::Dir
    @results = [] of Bool
    @step : UInt16

    getter config

    def initialize(@configfile : String)
      @config = load_config()
      @filedata = load_file()

      @dir = Dir.new(@config.limits.per_dir)

      @step = (@config.limits.count / 10).to_u16
    end

    def load_config
      config = File.open(@configfile) do |file|
        Config.from_yaml(file)
      rescue File::NotFoundError
        raise("cannot read file: #{@configfile}")
      rescue ex : YAML::ParseException
        raise("#{@configfile} contains invalid YAML: #{ex}")
      end
    ensure
      Log.trace {"Config loaded from #{@configfile}"}
    end

    def load_file
      contents = File.open(@config.storage.upload) do |file|
        file.gets_to_end
      end
    ensure
      Log.debug {"Sample file loaded from #{@config.storage.upload}"}
      Log.trace {"  file size: #{contents && contents.size || 0}"}
    end

    def new_client
      Awscr::S3::Client.new(
        @config.service.region || "us-east-1",
        @config.service.keys.access,
        @config.service.keys.secret,
        endpoint: @config.service.endpoint,
      )
    ensure
      Log.trace {"Created new connection to: #{@config.service.endpoint}"}
    end

    def ensure_bucket
      bucket = @config.storage.bucket
      new_client.head_bucket(bucket)
    rescue ex : Exception
      new_client.put_bucket(bucket)
    ensure
      Log.debug {"Using bucket: #{bucket}"}
    end

    def run
      ensure_bucket()

      time_start = Time.utc.to_unix

      Log.info {"Starting run"}
      Log.debug {"  concurrency is: #{@config.limits.concurrency}"}

      pool = Fiberpool.new(
        1..@config.limits.count,
        @config.limits.concurrency
      )

      pool.run do |_iteration|
        @results << upload()
        show_progress()
      end

      time_ended = Time.utc.to_unix

      time_elapsed = time_ended - time_start

      return @results
    ensure
      summary(time_elapsed || 0)
    end

    def show_progress
      if @results.size > (@config.limits.count - @step)
        return
      end

      progress = @results.size / @step

      if progress.to_i.to_f == progress
        progress = progress * 10
        Log.notice {" -  #{progress.to_i}%"}
      end
    end

    def upload
      filepath = "#{@dir.get}/#{UUID.random.to_s}.png"

      Log.trace {"Uploading to: #{filepath} (#{@filedata.size})"}

      client = new_client()
      uploader = Awscr::S3::FileUploader.new(client)

      result = uploader.upload(
        @config.storage.bucket,
        filepath,
        IO::Memory.new(@filedata)
      )

      return result
    rescue ex : Exception
      Log.error {"Upload failed: #{filepath}"}
      Log.debug {"  exception: #{ex}"}
      return false
    end

    def summary(time_elapsed)
      success = @results.count(true)
      failed = @results.count(false)

      status = @results.size == @config.limits.count ? "completed" : "ended"

      Log.info  {"\nRun #{status} in #{time_elapsed}s:"}
      Log.warn  {"   target: #{@config.limits.count}"}
      Log.info  {"  success: #{success}"}
      Log.error {"   failed: #{failed}"}
    end
  end

end
