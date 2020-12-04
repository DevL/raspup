# RaspUp
Raspberry Pi Setup Scripts

These scripts are intended to be run on a Mac just after imaging to a SD card. 

### Features
* Enables SSH on boot.
* Enables WLAN on boot and connects to a given network.
* Updates the system software.
* Installs the `micro` and `vim` text editors.
* Installs the `asdf` version manager.
* Installs latest `Erlang` from source (compiles it).
* Installs latest `Elixir`.
* Installs latest `Ruby`.

### Known issues
* Hardcoded username in the init.sh and setup.sh scripts.
* Only handles Raspberry OS images as Ubuntu names the boot volume "startup-boot".

### Ideas
* Use [supervisord](http://supervisord.org) to start permanent elixir nodes? 
