require 'spec_helper'

describe Investor do
  describe 'class methods' do
    describe 'starts_with' do
      it 'should call starts_with_non_alpha if 0 is passed in' do
        Person.should_receive(:starts_with_non_alpha)
        Person.starts_with('0')
      end

      it 'should cal starts_with_letter if a letter is passsed in' do
        Person.should_receive(:starts_with_letter).with('a')
        Person.starts_with('a')
      end

      it 'should not call any scope if a nil is passed in' do
        expect(Person.starts_with(nil).to_sql).to eql(Person.where(nil).to_sql)
      end
    end
  end

  describe 'instance methods' do
    describe 'guid' do
      it 'should include the class name and id, see the investor method' do
        person = Person.new(id: 1)
        expect(person.guid).to eql('person-1')
      end

      it 'should match the investment guid' do
        investor = Person.new(id: 1)
        investment = Investment.new(investor: investor)
        expect(investment.investor_guid).to eql(investor.guid)
      end
    end
  end
end
