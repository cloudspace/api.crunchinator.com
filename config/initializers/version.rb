module Crunchinator
  # The purpose of this is to store the name of the last git tab as a
  # constant for use during the process of pushing json to S3
  class Application
    VERSION = `git tag`.split.last
  end
end
