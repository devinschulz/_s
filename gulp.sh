#!/bin/sh

cd "$(dirname "$0")"

if [ ! gem spec sass > /dev/null 2>&1 && ! gem spec scss-lint > /dev/null 2>&1 ];
  then
    echo "Installing Ruby Gems"
    bundle install
fi

if [ ! -d node_modules ];
  then
    echo "Installing Dependencies"
    npm install
fi

if [ ! -d vendors ];
  then
    echo "Installing Bower"
    npm install bower
    bower install
fi

echo "Everything looks good, running Gulp!"

gulp