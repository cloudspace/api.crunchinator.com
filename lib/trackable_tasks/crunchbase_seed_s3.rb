require 's3'
require 'json/stream'
require 'fileutils'

class CrunchbaseSeedS3 < TrackableTasks::Base
  def run
    FileUtils.mkdir_p("companies/") unless File.directory?("companies/")
    companies = Company.get_all_companies
    s3_service = S3::Service.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    crunchinator_bucket = s3_service.buckets.find("crunchinator.com")

    companies.each do |c|
      puts "Pulling data for #{c["permalink"]}"
      Net::HTTP.start("api.crunchbase.com") do |http|
        resp = http.get("/v/1/company/#{c["permalink"]}.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
        
        if(resp.code == "429")
          puts "API limit reached"
          sleep(3600)
          puts "Restarting pull starting with #{c["permalink"]}"
          resp = http.get("/v/1/company/#{c["permalink"]}.js?api_key=#{ENV["CRUNCHBASE_API_KEY"]}")
        end

        open("companies/#{c["permalink"]}.json", "wb") do |f|
          puts "lolololol"
          f.write(resp.body)
          puts "Wrote data for #{c["permalink"]}"
        end

        Thread.new("#{c["permalink"]}.json") do |file_name|
          open("companies/#{file_name}", "r") do |f|
            #new_company = crunchinator_bucket.objects.build(file_name)
            #new_company.content = f
            #new_company.save
          end
          puts "#{c["permalink"]} was uploaded to S3"
        end
      end
    end
  end
end
