require 'spec_helper'

describe Company do
  describe 'class methods' do
    describe 'get all companies' do
      it 'should return a json list of companies'
    end

    describe 'process company' do
      it 'should create a company'
      it 'should build funding rounds for specified company'
      it 'should build investments for funding rounds'
      it 'should build investors for investments'
      it 'should write to logfile [log/import.log] if unable to normalize'
    end

    describe 'parse company info' do
      it 'should return newly created Company if successful'
      it 'should return nil if Company object could not be created'
    end

    describe 'create company' do
      it 'should create a company Object from a dictionary'
    end
  end
end
