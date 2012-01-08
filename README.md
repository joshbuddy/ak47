# Ak47

Ak47 is a general purpose reloader. It allows you to reload any command line argument based on either time or
file system change events. File system change events are only supported on Windows, Mac, and Linux.

## Installation

    gem install ak47

## Usage

To start an application using ak47, just prepend the entire command with ak47. For example:

    ak47 bundle exec thin -R config.ru start

This will run your webserver, but will reload it if there are any changes in your working directory.

There are a few command line options as well:

  * -m / --maximum Maximum time to wait before restarting, if unspecified wait forever.
  * -i / --interval Interval of time to wait before restarting in the event of a restart. Defaults to 0.01 seconds.
  * -e / --error-time Amount of time to wait between restarts if there was an error. Defaults to 5 seconds.
  
Any remaining arguments passed to the path will be interpretted as directories to watch. To stop parsing command line arguments
and enter your command, use `--` to seperate options from your command. For example:

    ak47 -i2 test -- rake test

This will watch your `test` directory and wait two seconds between restarts.

### Programmatic Usage

You can use Ak47 within a Ruby program in the following way.

    require 'ak47'
    Ak47 {
      puts "Reloading!"
    }
