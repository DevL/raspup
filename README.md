# RaspUp
Raspberry Pi Setup Scripts

These scripts are intended to be run on a Mac just after imaging to a SD card. 

### Features
* Enables SSH on boot.
* Enables WLAN on boot and connects to a given network.
* Replaces the default user with a specified one with a specified password.
* Copies SSH public keys for passwordless access.
* Updates the system software.
* Installs the `micro` and `vim` text editors.
* Installs the `asdf` version manager.
* Installs latest `Erlang` from source (compiles it).
* Installs latest `Elixir`.
* Installs latest `Ruby`.

### Known issues
* Only handles Raspberry OS images as Ubuntu names the boot volume "startup-boot".
* Only handles the id_rsa.pub SSH key.

### Ideas
* Use [supervisord](http://supervisord.org) to start permanent elixir nodes? 
