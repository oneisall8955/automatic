#!/bin/bash -e
apt -y install ruby
apt -y install rubygems
gem sources -r https://rubygems.org/
gem sources -a https://gems.ruby-china.com/
gem install redis
