namespace :version do
  task :bump, [:segment] => [:environment] do |t, args|
    prompt_user 'You are about to release a new app version. Continue?'
    Versioner::Git.ensure_staging_area_clear
    Versioner::Git.ensure_master
    if args.segment
      versioner = Versioner.new(args.segment)
      versioner.bump
      versioner.write_app_version
      puts "EXECUTING: `git add VERSION`"
      puts `git add VERSION`
      puts "EXECUTING: `git commit -m \"bumping version from #{versioner.original_version} to #{versioner.version}\"`"
      puts `git commit -m \"bumping version from #{versioner.original_version} to #{versioner.version}\"`
      puts "EXECUTING: `git tag #{versioner.version}`"
      puts `git tag #{versioner.version}`
      puts "To complete the tagging process, run: 'git push origin master && git push origin --tags'"
    else
      puts 'please specify a segment to bump (major/minor/patch)'
    end
  end
end

def prompt_user(prompt)
  STDOUT.print prompt + ' (yes/NO): '
  input = STDIN.gets.strip
  unless input.downcase == 'yes'
    puts 'Exiting!'
    exit
  end
end

class Versioner
  class Git
    class << self
      def ensure_master
        unless Git.current_branch == 'master'
          puts "You are not on the master branch, exiting."
          exit
        end
      end

      def ensure_staging_area_clear
        if staged_changes?
          puts "You have uncommitted staged changes, exiting. Please clear your git staging area."
          exit
        end
      end

      def current_branch
        `git branch | grep '*'`.gsub('*', '').strip
      end

      def staged_changes?
        `git diff --staged`.strip != ''
      end
    end
  end

  def initialize(segment)
    @segment = segment
    raise 'invalid argument' unless [:major, :minor, :patch].include?(@segment.to_sym)
    @original_version = File.read(File.join(Rails.root, 'VERSION'))
    @major, @minor, @patch = @original_version.sub('v','').split('.')
  end

  attr_accessor :original_version, :segment, :major, :minor, :patch

  def bump
    sym = ('@' + @segment.to_s).to_sym
    instance_variable_set(sym, (instance_variable_get(sym).to_i + 1).to_s)
  end

  def version
    'v' + [@major, @minor, @patch].join('.')
  end

  def write_app_version
    prompt_user "Bumping #{@segment.upcase} from #{@original_version} to #{version}. Continue?"
    File.open(File.join(Rails.root, 'VERSION'), 'w') { |file| file.write(version) }
    puts "VERSION file saved"
  end
end
