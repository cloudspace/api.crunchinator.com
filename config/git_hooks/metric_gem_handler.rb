# Handles execution and printing of code metric gems specified in the exec method
# Literally it just takes a command and prints results and returns false if it fails
#
# It will only exit with a status of 1 if you are on a major branch (master, development, staging)
# And you are pushing.
# 
# If you are just commiting it won't keep you from committing but it will print the errors
#
# @!attribute [] git_hook_type
#   @return [Integer] which type of git hook this class is being used on [:commit or :push]
#
# @!attribute [] git_branch
#   @return [String] The current git branch the user is on
#
# @!attribute important_branches
#   @return [Array] List of important branches that we should not allow a push if there are errors
#
# @!attribute logger
#   @return Logger new logger created to point error messages to log/code_metrics.log
#
# Something doesn't feel right about this class but hey its alpha so we'll probably need to re-write it

require 'logger'


class MetricGemHandler
  #--------------------------------
  # Constants
  #--------------------------------
  
  GIT_HOOKS = {
    :commit => 1,
    :push => 2
  }
  
  #--------------------------------
  # Methods
  #--------------------------------
  
  #
  # Initializes the class with default variables
  #
  # @param git_hook_type [Symbol] What type of hook we are creating this class for :commit or :push
  #
  # @return nil
  def initialize(git_hook_type = :commit)
    @git_hook_type = GIT_HOOKS[git_hook_type.to_sym] || (raise "Invalid Git Hook Type")
    @git_branch = `git branch | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\1/'`.strip!
    # @git_branch = "development"
    @important_branches=%w(staging stage master development)
    @logger = Logger.new('./log/code_metrics.log')
  end

  
  
  # 
  # Runs the command and then prints the output if it fails
  #
  # @param name [String] Name of the code metric gem for logging purposes
  # @param cmd [String] The command to be processed
  #
  # @return [Boolean]
  def exec(name, cmd)
    results = `#{cmd}`
    @logger.debug <<-eos
    
    
    ##########################################
    #
    # Begin #{name}
    #
    ##########################################
    eos
    return print_and_fail($?,results)
  end
  
  
  private 
  
  #
  # Prints any errors and returns false if it shouldn't execute the git command
  #
  # @param result [$?] The process that ran the script
  # @param text [String] String returned from the script that ran
  #
  # @return [Boolean]
  def print_and_fail(result,text)
    if(result.exitstatus != 0)  
      @logger.debug text
      # we need to show bad commits every time
      if(@git_hook_type == GIT_HOOKS[:commit])
        return false
      end
      # we need to only show bad pushes when its an important branch
      if(@git_hook_type == GIT_HOOKS[:push] && @important_branches.include?(@git_branch))
        return false
      end
    end
    return true
  end
end
