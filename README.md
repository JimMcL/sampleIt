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

* Ruby version (output of ruby --version):
ruby 2.5.3p105 (2018-10-18 revision 65156) [x64-mingw32]

* Installed gems (output of gem list)
  * actioncable (5.2.2, 5.0.7)
  * actionmailer (5.2.2, 5.0.7)
  * actionpack (5.2.2, 5.0.7)
  * actionview (5.2.2, 5.0.7)
  * activejob (5.2.2, 5.0.7)
  * activemodel (5.2.2, 5.0.7)
  * activerecord (5.2.2, 5.0.7)
  * activestorage (5.2.2)
  * activesupport (5.2.2, 5.0.7)
  * addressable (2.7.0)
  * annotate (2.7.3)
  * arel (9.0.0, 7.1.4)
  * bigdecimal (default: 1.3.4)
  * bindex (0.5.0)
  * builder (3.2.4, 3.2.3)
  * bundler (1.17.1)
  * cmath (default: 1.0.0)
  * coffee-rails (4.2.2)
  * coffee-script (2.4.1)
  * coffee-script-source (1.12.2)
  * concurrent-ruby (1.1.5, 1.0.5)
  * crass (1.0.5, 1.0.4)
  * csv (default: 1.0.0)
  * date (default: 1.0.0)
  * dbm (default: 1.0.0)
  * did_you_mean (1.2.0)
  * erubi (1.7.1)
  * erubis (2.7.0)
  * etc (default: 1.0.0)
  * execjs (2.7.0)
  * faraday (0.17.0)
  * fcntl (default: 1.0.0)
  * ffi (1.9.25 x64-mingw32)
  * fiddle (default: 1.0.0)
  * fileutils (default: 1.0.2)
  * gdbm (default: 2.0.0)
  * globalid (0.4.1)
  * google-cloud-vision (0.37.0)
  * google-gax (1.8.1)
  * google-protobuf (3.10.1 x64-mingw32)
  * googleapis-common-protos (1.3.9)
  * googleapis-common-protos-types (1.0.4)
  * googleauth (0.10.0)
  * grpc (1.24.0 x64-mingw32)
  * i18n (1.7.0, 1.0.1)
  * io-console (default: 0.4.6)
  * ipaddr (default: 1.2.0)
  * jbuilder (2.7.0)
  * jquery-rails (4.3.3)
  * jquery-ui-rails (6.0.1)
  * json (default: 2.1.0)
  * jwt (2.2.1)
  * lazyload-rails (0.3.1)
  * loofah (2.4.0, 2.2.2)
  * mail (2.7.0)
  * marcel (0.3.3)
  * memoist (0.16.0)
  * method_source (0.9.0)
  * mimemagic (0.3.2)
  * mini_mime (1.0.0)
  * mini_portile2 (2.4.0, 2.3.0)
  * minitest (5.13.0, 5.11.3, 5.10.3)
  * multi_json (1.13.1)
  * multipart-post (2.1.1)
  * net-telnet (0.1.1)
  * nio4r (2.3.1)
  * nokogiri (1.10.7 x64-mingw32, 1.8.2 x64-mingw32)
  * openssl (default: 2.1.2)
  * os (1.0.1)
  * power_assert (1.1.1)
  * psych (default: 3.0.2)
  * public_suffix (4.0.1)
  * puma (3.11.4)
  * rack (2.0.5)
  * rack-test (0.6.3)
  * rails (5.2.2, 5.0.7)
  * rails-dom-testing (2.0.3)
  * rails-html-sanitizer (1.3.0, 1.0.4)
  * rails_autolink (1.1.6)
  * railties (5.2.2, 5.0.7)
  * rake (12.3.1, 12.3.0)
  * rb-fsevent (0.10.3)
  * rb-inotify (0.9.10)
  * rdoc (default: 6.0.1)
  * rly (0.2.3)
  * sass (3.5.6)
  * sass-listen (4.0.0)
  * sass-rails (5.0.7)
  * scanf (default: 1.0.0)
  * sdbm (default: 1.0.0)
  * signet (0.12.0)
  * sprockets (3.7.2)
  * sprockets-rails (3.2.1)
  * sqlite3 (1.4.2, 1.3.13 x64-mingw32)
  * stringio (default: 0.0.1)
  * strscan (default: 1.0.0)
  * test-unit (3.2.7)
  * thor (0.20.0)
  * thread_safe (0.3.6)
  * tilt (2.0.8)
  * turbolinks (5.1.1)
  * turbolinks-source (5.1.0)
  * tzinfo (1.2.5)
  * tzinfo-data (1.2018.5)
  * uglifier (4.1.10)
  * web-console (3.6.2)
  * webrick (default: 1.4.2)
  * websocket-driver (0.6.5)
  * websocket-extensions (0.1.3)
  * will_paginate (3.1.6)

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