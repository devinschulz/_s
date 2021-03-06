#!/bin/sh

cd "$(dirname "$0")"

if [ ! gem spec sass > /dev/null 2>&1 && ! gem spec scss-lint > /dev/null 2>&1 ];
  then
    echo "Installing Ruby Gems"
    bundle install
fi

node=`which node 2>&1`
if [ $? -ne 0 ]; then
  echo "Please install NodeJS."
  echo "http://nodejs.org/"
  exit 1
fi

npm=`which npm 2>&1`
if [ $? -ne 0 ]; then
  echo "Please install NPM."
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

if [ ! -d assets/images/sprite ];
  then
    echo "Creating Directories"
    cd assets
    if [ ! -d assets/images ];
      then
        echo "Creating Images Directory"
        mkdir images
    fi
    if [ ! -d assets/images/sprite ];
      then
        echo "Creating Sprite Directory"
        cd images
        mkdir sprite
    fi
fi

echo "Everything looks good, running Gulp!"

gulp
