class CrunchbaseStartWorkers < TrackableTasks::Base
  def run
    threads = []
    25.times do |index|
      threads << Thread.new(index) do |_threadIndex|
        worker = ApiQueue::Worker.new(id: _threadIndex)
        worker.run
      end
    end

    threads.each(&:join)
  end
end