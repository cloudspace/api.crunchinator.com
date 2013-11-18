# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load custom environment variables
environment_variables = File.join(Rails.root, 'config', 'environment_variables.rb')
load(environment_variables) if File.exists?(environment_variables)

# Initialize the Rails application.
Crunchinator::Application.initialize!
