wiretool - the quick crappy bash script to connect to wifi networks

depends on:
	- wireless_tools
	- wpa_suppilcant

setup:
	1. set the "dev" variable to your wireless device
	2. set the "wpa_dir" variable to a dir of your choosing
	3. set the "null_dev" variable to the path to your null device

usage:
	- "scan" to scan for networks
		note: if it does not work, try to "flush" or "reset"
	- "con" followed by the ESSID of the network
		use wpa after network ESSID if it is not an open network
		IF THE ESSID HAS SPACES, use "+s+" to replace them
	- "flush" to flush network info from the interface
	- "reset" to do a hard reset
	- "version" to print the version
