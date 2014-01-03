require 'spec_helper'

describe ApiQueue::Element do
  
  describe "validations" do
    it { should validate_presence_of :permalink }
    it { should validate_uniqueness_of :permalink }
  end
  
  describe "fields" do
    it { should respond_to :num_runs }
    it { should respond_to :processing }
    it { should respond_to :complete}
    it { should respond_to :last_attempt_at }
    it { should respond_to :permalink }
    it { should respond_to :error }
    it { should respond_to :data_source }
    it { should respond_to :namespace }
  end
  
  describe 'scopes' do
    describe 'errors' do
      before(:each) do
        @blank_string_error = FactoryGirl.create(:api_queue_element, error: "")
        @nil_error = FactoryGirl.create(:api_queue_element, error: nil)
        @has_error = FactoryGirl.create(:api_queue_element, error: "this is an error")
        @elements_with_errors = ApiQueue::Element.errors
      end

      it 'should include an Element with an error' do
        expect(@elements_with_errors).to include(@has_error)
      end
      
      #an error occurred - even if it records a blank string, this is how it is coded
      it 'should include an Element with a blank string error value' do
        expect(@elements_with_errors).to include(@blank_string_error)
      end

      it 'should not include an Element with a nil error value' do
        expect(@elements_with_errors).not_to include(@nil_error)
      end
    end

    describe 'complete' do
      before(:each) do
        @complete_element = FactoryGirl.create(:api_queue_element, complete: true)
        @incomplete_element = FactoryGirl.create(:api_queue_element, complete: false)
        @complete_elements = ApiQueue::Element.complete
      end

      it 'should include a completed Element' do
        expect(@complete_elements).to include(@complete_element)
      end

      it 'should not include an incomplete Element' do
        expect(@complete_elements).not_to include(@incomplete_element)
      end
    end
    
    describe 'incomplete' do
      before(:each) do
        @complete_element = FactoryGirl.create(:api_queue_element, complete: true)
        @incomplete_element = FactoryGirl.create(:api_queue_element, complete: false)
        @incomplete_elements = ApiQueue::Element.incomplete
      end

      it 'should not include a completed Element' do
        expect(@incomplete_elements).not_to include(@complete_element)
      end

      it 'should include an incomplete Element' do
        expect(@incomplete_elements).to include(@incomplete_element)
      end
    end
    
    describe 'processing' do
      before(:each) do
        @processed_element = FactoryGirl.create(:api_queue_element, processing: true)
        @not_processed_element = FactoryGirl.create(:api_queue_element, processing: false)
        @processed_elements = ApiQueue::Element.processing
      end

      it 'should include a processed Element' do
        expect(@processed_elements).to include(@processed_element)
      end

      it 'should not include an Element that has not been processed' do
        expect(@processed_elements).not_to include(@not_processed_element)
      end
    end
    
    describe 'not_processing' do
      before(:each) do
        @processed_element = FactoryGirl.create(:api_queue_element, processing: true)
        @not_processed_element = FactoryGirl.create(:api_queue_element, processing: false)
        @not_processed_elements = ApiQueue::Element.not_processing
      end

      it 'should not include a processed Element' do
        expect(@not_processed_elements).not_to include(@processed_element)
      end

      it 'should include an Element that has not been processed' do
        expect(@not_processed_elements).to include(@not_processed_element)
      end
    end

    describe 'not_failed' do
      before(:each) do
        @failed_element = FactoryGirl.create(:api_queue_element, num_runs: 5)
        @not_failed_element = FactoryGirl.create(:api_queue_element, num_runs: 4)
        @not_failed_elements = ApiQueue::Element.not_failed
      end

      it 'should not include a failed Element' do
        expect(@not_failed_elements).not_to include(@failed_element)
      end

      it 'should include an Element that has not failed' do
        expect(@not_failed_elements).to include(@not_failed_element)
      end
    end
    
    describe 'failed' do
      before(:each) do
        @failed_element = FactoryGirl.create(:api_queue_element, num_runs: 5)
        @not_failed_element = FactoryGirl.create(:api_queue_element, num_runs: 4)
        @failed_elements = ApiQueue::Element.failed
      end

      it 'should not include a failed Element' do
        expect(@failed_elements).not_to include(@not_failed_element)
      end

      it 'should include an Element that has not failed' do
        expect(@failed_elements).to include(@failed_element)
      end
    end
    
    describe 'waiting_for_retry' do
      before(:each) do
        @ran_but_not_complete = FactoryGirl.create(:api_queue_element, num_runs: 1, complete: false)
        @completed = FactoryGirl.create(:api_queue_element, complete: true)
        @not_run = FactoryGirl.create(:api_queue_element, num_runs: 0)
        @waiting_elements = ApiQueue::Element.waiting_for_retry
      end

      it 'should include an element that has run and not completed' do
        expect(@waiting_elements).to include(@ran_but_not_complete)
      end
      
      it 'should not include an element that has completed' do
        expect(@waiting_elements).not_to include(@ran_and_complete)
      end
      
      it 'should not include an element that has not run' do
        expect(@waiting_elements).not_to include(@not_run)
      end
    end    
    
    describe 'order_by_fifo' do
      before(:each) do
        @element_1 = FactoryGirl.create(:api_queue_element, num_runs: 1, complete: false)
        @element_2 = FactoryGirl.create(:api_queue_element, complete: true)
        @ordered_elements = ApiQueue::Element.order_by_fifo
      end

      it 'the element created first to be first' do
        expect(@ordered_elements.first.id).to eql(@element_1.id)
      end
      
      it 'the element created last to be last' do
        expect(@ordered_elements.last.id).to eql(@element_2.id)
      end
    end

    describe 'order_by_most_recently_modified' do
      before(:each) do
        @element_1 = FactoryGirl.create(:api_queue_element, )
        @element_2 = FactoryGirl.create(:api_queue_element, )
        @ordered_elements = ApiQueue::Element.order_by_most_recently_modified
      end

      it 'the element created last to be first' do
        expect(@ordered_elements.first.id).to eql(@element_2.id)
      end
      
      it 'the element created first to be last' do
        last_element = @ordered_elements.last.id
        expect(last_element).to eql(@element_1.id)
      end
      
      it 'the element last saved will be first' do
        @element_1.complete = true
        @element_1.save
        @ordered_elements = ApiQueue::Element.order_by_most_recently_modified
        expect(@ordered_elements.first.id).to eql(@element_1.id)
      end
    end
    
    # Elements with a no last attempt or a last attempt more than 1 hour ago
    # scope :not_recently_errored, lambda { where("last_attempt_at is null OR last_attempt_at < :an_hour_ago", {:an_hour_ago => Time.now - 1.hour}) }
    describe 'not_recently_errored' do
      before(:each) do
        @element_no_attempt = FactoryGirl.create(:api_queue_element, )
        @element_hour_old_attempt = FactoryGirl.create(:api_queue_element, last_attempt_at: 2.hours.ago)
        @element_recent_attempt = FactoryGirl.create(:api_queue_element, last_attempt_at: 1.minute.ago)
        @not_recent_elements = ApiQueue::Element.not_recently_errored
      end

      it 'will include elements with no attempts' do
        expect(@not_recent_elements).to include(@element_no_attempt)
      end
      
      it 'will include elements with attempts over an hour old' do
        expect(@not_recent_elements).to include(@element_hour_old_attempt)
      end
      
      it 'will not include elements with attempts less than an hour old' do
        expect(@not_recent_elements).not_to include(@element_recent_attempt)
      end
    end
    

    
  end
    
    # 
    # # Elements with a no last attempt or a last attempt more than 1 hour ago
    # scope :not_recently_errored, lambda { where("last_attempt_at is null OR last_attempt_at < :an_hour_ago", {:an_hour_ago => Time.now - 1.hour}) }
    # 
    # # Elements that match all of the above scopes
    # scope :pending, lambda { incomplete.not_processing.not_recently_errored.not_failed }
  describe 'instance methods' do
    before(:each) do
      @api_queue_element = ApiQueue::Element.new
    end

    describe 'mark_for_processing' do
      it 'should set the processing attribute to true' do
        @api_queue_element.mark_for_processing
        expect(@api_queue_element.processing).to eql(true)
      end
    end
  end
  
end
