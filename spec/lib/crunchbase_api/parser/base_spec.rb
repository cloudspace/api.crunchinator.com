require 'spec_helper'

describe ApiQueue::Parser::Base do
  describe "class methods" do
    describe "safe_find_or_create_by and associated mutex methods" do
      describe "meta_mutex and mutexes instance variables" do
        it "should include the mutees" do
          ApiQueue::Parser::Base.instance_variables.should include(:@meta_mutex)
          ApiQueue::Parser::Base.instance_variables.should include(:@mutexes)
        end

        it "mutexes should be accessible" do
          ApiQueue::Parser::Base.should respond_to :mutexes
        end
      end

      describe "get_mutex" do
      end

      describe "safe_find_or_create_by" do
      end
    end

    describe "prcoess_entity" do
    end

    describe "model creation methods" do
      describe "create_company" do
      end

      describe "create_office_location" do
      end

      describe "create_category" do
      end

      describe "create_financial_org" do
      end

      describe "create_funding_round" do
      end

      describe "create_investment" do
      end

      describe "create_person" do
      end
    end
  end
end
