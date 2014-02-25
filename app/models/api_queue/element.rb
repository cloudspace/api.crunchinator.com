# item in the queue of api requests
class ApiQueue::Element < ActiveRecord::Base
  self.table_name = 'api_queue_elements'

  validates :permalink, uniqueness: true, presence: true

  # errors
  scope :errors, -> { where.not(error: nil) }

  # FIFO Queue order
  scope :order_by_fifo, -> { order(:id) }

  # Order by most recently modified
  scope :order_by_most_recently_modified, -> { order(updated_at: :desc) }

  # Elements that are flagged as complete
  scope :complete, -> { where(complete: true) }

  # Elements that are not flagged as complete
  scope :incomplete, -> { where(complete: false) }

  # Elements currently being processed
  scope :processing, -> { where(processing: true) }

  # Elements not currently being processed
  scope :not_processing, -> { where(processing: false) }

  # Elements with a no last attempt or a last attempt more than 1 hour ago
  scope :not_recently_errored, lambda {
    where('last_attempt_at is null OR last_attempt_at < ?', 1.hour.ago)
  }

  # Elements with less than 5 attempts
  scope :not_failed, -> { where('num_runs < 5') }

  # Elements that match all of the above scopes
  scope :pending, -> { incomplete.not_processing.not_recently_errored.not_failed }

  # Elements that have failed (they have been attempted 5 times and still haven't succeeded)
  scope :failed, -> { where('num_runs >= 5').incomplete }

  # Elements that have errored and are marked for retry
  scope :waiting_for_retry, -> { incomplete.where('num_runs > 0') }

  # flags an element to indicate it is being processed
  def mark_for_processing
    update_attributes(processing: true)
  end
end
