require "./spec_helper"

describe S3t do

  # it "works" do
  #   false.should eq(true)
  # end

  it "should complete a run" do
    # basic log checks
    logs.check(:trace, /config loaded/i)
    logs.check(:debug, /sample file loaded/i)
    logs.check(:trace, /created new connection to:.*#{address}:#{port.to_s}/i)
    logs.check(:info, /starting run/i)
    logs.check(:info, /run (completed|ended)/i)
  end
end
