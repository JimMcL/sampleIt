# README

A simple Ruby on Rails application to manage biology specimens. The
goal of this app is to make it simple to maintain accurate, complete
and error-free specimen data.

A specimen belongs to a site, which is the time and place that the
specimen was collected. Sites belong to a project. Multiple specimens
may have been collected at a single site. A specimen may be identified
as having a taxon (e.g. a species). Specimens can have photos.

A design goal is to make it as easy as possible to access the
data. There are no access restrictions. Photos are stored in the
public/images folder so they are served directly by the web server for
maximum speed. This means that anyone with access to the server can
see **and edit** all of the data and photos.

It uses a vanilla RoR setup.

* TODO

  * Allow relative urls in taxon descriptions.

* Ruby version:
ruby 2.2.4p230 (2015-12-16 revision 53155) [i386-mingw32]

* Installed gems
  * actioncable (5.0.1, 5.0.0.1)
  * actionmailer (5.0.1, 5.0.0.1)
  * actionpack (5.0.1, 5.0.0.1)
  * actionview (5.0.1, 5.0.0.1)
  * activejob (5.0.1, 5.0.0.1)
  * activemodel (5.0.1, 5.0.0.1)
  * activerecord (5.0.1, 5.0.0.1)
  * activesupport (5.0.1, 5.0.0.1)
  * annotate (2.7.1)
  * arel (7.1.4)
  * bigdecimal (1.2.6)
  * builder (3.2.2)
  * bundler (1.13.6)
  * coffee-rails (4.2.1)
  * coffee-script (2.4.1)
  * coffee-script-source (1.12.2, 1.11.1)
  * concurrent-ruby (1.0.3, 1.0.2)
  * debug_inspector (0.0.2)
  * erubis (2.7.0)
  * execjs (2.7.0)
  * fastercsv (1.5.5)
  * globalid (0.3.7)
  * i18n (0.7.0)
  * io-console (0.4.3)
  * jbuilder (2.6.1)
  * jquery-rails (4.2.1)
  * jquery-ui-rails (6.0.1)
  * json (2.0.2, 1.8.1)
  * lazyload-rails (0.3.1)
  * loofah (2.0.3)
  * mail (2.6.4)
  * method_source (0.8.2)
  * mime-types (3.1)
  * mime-types-data (3.2016.0521)
  * mini_portile2 (2.1.0, 2.0.0)
  * minitest (5.10.1, 5.4.3)
  * multi_json (1.12.1)
  * nio4r (1.2.1)
  * nokogiri (1.6.8.1 x86-mingw32, 1.6.7.2 x86-mingw32)
  * power_assert (0.2.2)
  * psych (2.0.8)
  * puma (3.6.2)
  * rack (2.0.1)
  * rack-test (0.6.3)
  * rails (5.0.1, 5.0.0.1)
  * rails-dom-testing (2.0.1)
  * rails-html-sanitizer (1.0.3)
  * railties (5.0.1, 5.0.0.1)
  * rake (12.0.0, 11.3.0, 10.4.2)
  * rdoc (4.2.0)
  * sass (3.4.23, 3.4.22)
  * sass-rails (5.0.6)
  * sprockets (3.7.1, 3.7.0)
  * sprockets-rails (3.2.0)
  * sqlite3 (1.3.12 x86-mingw32, 1.3.11 x86-mingw32)
  * test-unit (3.0.8)
  * thor (0.19.4)
  * thread_safe (0.3.5)
  * tilt (2.0.5)
  * turbolinks (5.0.1)
  * turbolinks-source (5.0.0)
  * tzinfo (1.2.2)
  * tzinfo-data (1.2016.10)
  * uglifier (3.0.4)
  * web-console (3.4.0)
  * websocket-driver (0.6.4)
  * websocket-extensions (0.1.2)
  * will_paginate (3.1.5)

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

 Install Ruby and Ruby on Rails.
 
 Pre-compiled assets are not checked in to
 revision control. That means it is necessary to precompile them as
 part of a production deployment. To do so, run the command
 `$ bundle exec rake assets:precompile`

 On Windows, the server can be run using `server.bat [-p]`. If running
 production (-p option), it is necessary to first create a file called
 `SECRET_KEY_BASE.bat` which sets the environment variable
 SECRET_KEY_BASE. The file should contain:  
 `set SECRET_KEY_BASE=<secret>`  
 where `<secret>` can be generated with the command:  
 `bundle exec rake secret`

For managing secret keys etc. on Ubuntu, refer to [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04).

Various external image utilities are used to construct thumbnails and so on.
Currently the executable names (and sometimes paths) are simply hard-wired.
See lib/image_utils.rb.