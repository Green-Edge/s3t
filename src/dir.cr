require "log"
require "uuid"

module S3t

  class Dir
    Log = ::Log.for(self)

    @name : String = UUID.random.to_s
    @uses : UInt32 = 0

    @max : UInt32

    def initialize(max)
      @max = max

      Log.debug {"Initialised dir using: #{@name}"}
    end

    def reset
      @name = UUID.random.to_s
      @uses = 0
      Log.debug {"Reset dir using: #{@name}"}
    end

    def get
      if @uses >= @max
        reset
      end

      @uses += 1

      @name
    end
  end

end
