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
    > gem install bundler
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
    
# API KEYS

To setup your keys from the root of the project run

  > cp config/environment_variables.rb.sample config/environment_variables.rb

Then add your env variables to the new file
