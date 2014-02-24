module Crunchinator
  # The purpose of this is to load last git tag into a
  # constant for use during the process of pushing json to S3
  class Application
    VERSION = File.open(File.join(Rails.root, 'VERSION'), &:read).strip
  end
end
