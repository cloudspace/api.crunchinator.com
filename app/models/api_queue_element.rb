class ApiQueueElement < ActiveRecord::Base
  validates :permalink, :uniqueness => true

  default_scope { order("id asc") }

  # Elements that are not flagged as complete
  scope :incomplete, lambda { where(:complete => false) }

  # Elements not currently being processed
  scope :not_processing, lambda { where(:processing => false) }

  # Elements with a no last attempt or a last attempt more than 1 hour ago
  scope :not_recently_errored, lambda { where("last_attempt_at is null OR last_attempt_at < :an_hour_ago", {:an_hour_ago => Time.now - 1.hour}) }

  # Elements with less than 5 attempts
  scope :not_failed, lambda { where("num_runs < 5") }

  # Elements that match all of the above scopes
  scope :pending, lambda { incomplete.not_processing.not_recently_errored.not_failed }

  # Elements that have failed (they have been attempted 5 times and still haven't succeeded)
  scope :failed, lambda { where("id not in (:pending_ids)", {:pending_ids => pending.pluck(:id)}) }
end
