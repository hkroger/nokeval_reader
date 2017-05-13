# Nokeval FTR970B Reader
This is a utility which reads the measurements of a wireless thermometer Measurinator.com service. This works with Nokeval FTR970B and compatible devices.

It can be run as a daemon and an example launchd configuration file is included.

## How to use
### Install requirements

Ruby 1.9 or newer is required. I recommend installing RVM from <https://rvm.io/>. After installing RVM and for example ruby 2.0, install needed gems:

    gem install bundler
	bundle install

### Check the configuration
Check the configuration and update as needed:

	cp config.yaml.example config.yaml
	vim config.yaml

Example of rest storage configuration with fail over urls:

    serial:
	    device: "/dev/tty.usbserial-NA140098"
	    baud: 9600
	    bits: 8
	    stopbits: 1
    database:
	    type: rest_storage
	    key: <some uuid>
	    client_id: <another uuid>
    buffer_file: "/opt/nokeval-reader/buffer.sqlite3"
  
It is important to update at least the serial device to point to the actual device that you have.

### Run
	./reader.rb
	
### Easy install for Debian/Raspbian 8

Open apt-get file in editor:

    vim /etc/apt/sources.list.d/temperaturinator.list

Add:

    deb http://koti.kapsi.fi/hkroger/debs/ ./

Save & run:

	apt-get update
	apt-get install nokeval-reader

Edit configs:

	cd /opt/nokeval_reader
	cp config.yaml.example config.yaml
	vim config.yaml
	
Add key where it says `<key here>` and client id where it says `<client id here>`.

And start the service

	systemctl start nokeval_reader

### Run as daemon in OS X

Copy daemon config and update paths and username settings:

	cp com.nokeval.temperature_reader.plist.example /Library/LaunchDaemons/com.nokeval.temperature_reader.plist
	vim /Library/LaunchDaemons/com.nokeval.temperature_reader.plist
	
Load and start the daemon. It is important to use *sudo* otherwise the daemon will be registered to your user account and will run only when you are logged in:

	sudo launchctl load /Library/LaunchDaemons/com.nokeval.temperature_reader.plist

That's it!

#### Disclaimer

I am not in anyway affiliated with Nokeval Oy. 
