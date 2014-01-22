## Crunchinator API

The crunchinator will pull in data from crunchbase, parse it, and create a restful json api to grab the data. 

### Setting up the development environment

#### Requirements:

- A [github](https://github.com/) account
- A cloudspace AWS validator key (cloudspace-validator.pem)
- [Virtualbox](https://www.virtualbox.org)
- [Vagrant](http://www.vagrantup.com/)
- [Git](http://git-scm.com/)

#### Instructions:

Clone the api.crunchinator.com repository and initialize/update the [chef solo](http://docs.opscode.com/chef_solo.html) cookbook submodules.

    > git clone git@github.com:cloudspace/api.crunchinator.com
    > cd api.crunchinator.com
    > librarian-chef install

Start the [Vagrant](vagrantup.com) box.  If there are issues starting, you may need to disable usb2 support for this virtual machine from inside virtual box.

    > cd api.crunchinator.com
    > vagrant up

Once started, we can log into the machine

    > vagrant ssh

    
Navigate to the project directory and bundle

    > cd /srv/api.crunchinator.com
    > sudo gem install bundler
    > bundle install

Once installation is complete, create, migrate, and seed the database

    > rake db:create db:migrate db:seed
    
At this point your project should be ready to go.  You can now start the development server.

    > sudo rails s -p 80
    
# Code Metric hooks

We have setup a couple of code metric gems as hooks when you commit and push to github.

To have those work please add the following symlinks from the root of the project

    > ln -s ../../config/git_hooks/pre-push ./.git/hooks/pre-push
    > ln -s ../../config/git_hooks/pre-commit ./.git/hooks/pre-commit
    > ln -s ./config/rubocop_settings.yml ./.rubocop.yml
    
# API KEYS

To setup your keys from the root of the project run

  > cp config/environment_variables.rb.sample config/environment_variables.rb

Then add your env variables to the new file

# Using the importer

The importer can be operated using rake tasks, or from the console

### Rake tasks

Empty the queue and clear the logs.
	
	rake api_queue:reset
	
Clears and populates the queue with all companies from crunchbase. The default data source is 'crunchbase'.

The options for the data source are 'local', 's3', and 'crunchbase'.

	rake api_queue:populate[<data source>]

Start the specified number of queue workers (defaults to 5 if no argument is given).

	rake api_queue:start_workers[<number of workers>]
	
Upload fresh JSON data to S3, gzipped, and set the ACL on the files to public. Note: Do not do this unless your local database is fully populated.

	rake api_queue:upload_data

Flush the queue, populate it, start the specified number of workers to process the queue, and upload JSON to S3 if the queue is processed successfully. The number of workers defaults to 5, and the data source defaults to crunchbase. If you have a new development environment and want to deploy, use run, set the source to 's3', and the number of workers to at least 10 (I have tested up to 25 and it works, but that that point you become more bandwidth-limited than worker-limited). Note: this can take a long time.

The options for the data source are 'local', 's3', and 'crunchbase'.

	rake api_queue:run[<number of workers>, <data source>]

### Console use

Everything that can be done using rake tasks can also be done at the console. For more details and documentation, look at lib/crunchbase_api/controller.rb
