class CrunchbaseCompanyList < TrackableTasks::Base
  def run
    puts Company.get_all_companies
  end
end
