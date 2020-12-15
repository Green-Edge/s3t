require "./spec_helper"

describe S3t do

  it "should complete a run" do
    # basic log checks
    Store.logs.check(:trace, /config loaded/i)
    Store.logs.check(:debug, /sample file loaded/i)
    Store.logs.check(:trace, /created new connection to:.*#{Store.address}:#{Store.port.to_s}/i)
    Store.logs.check(:info, /starting run/i)
    Store.logs.check(:info, /run (completed|ended)/i)
  end
end
