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
    > git submodule init
    > git submodele update

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