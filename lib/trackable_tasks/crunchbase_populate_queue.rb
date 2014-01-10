class CrunchbasePopulateQueue < TrackableTasks::Base
  def run
    ApiQueue::Queue.populate
  end
end
