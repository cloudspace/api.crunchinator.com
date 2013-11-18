# confg/environment_variables.rb holds web service keys and other sensitive data
# we don't want leaked to the public. Please add the appropriate keys to ensure
# that this API works correctly.
#
# This file has been added to .gitignore, any changes to it will not be tracked

ENV["CRUNCHBASE_API_KEY"] = ""
ENV["AWS_ACCESS_KEY_ID"] = ""
ENV["AWS_SECRET_ACCESS_KEY"] = ""
