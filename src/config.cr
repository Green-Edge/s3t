require "yaml"

module S3t

  class KeysConfig
    include YAML::Serializable

    property access : String
    property secret : String
  end

  class ServiceConfig
    include YAML::Serializable

    property endpoint : String
    property keys : KeysConfig
  end

  class StorageConfig
    include YAML::Serializable

    property bucket : String
    property upload : String
  end

  class LimitsConfig
    include YAML::Serializable

    property concurrency : Int32 = 10
    property count : UInt32
    property per_dir : UInt32
  end

  class Config
    include YAML::Serializable

    property service : ServiceConfig
    property storage : StorageConfig
    property limits : LimitsConfig
  end

end
