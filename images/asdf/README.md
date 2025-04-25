# asdf container

This is Alpine based `asdf` conatiner intended to be used as a development tool to enable quick and easy installation of the tools 
it also provides `asdf_install` command which can read `.tool-versions` from users `$HOME` and install missing plugin and tool with specified version

### Notes
1. ensure you are always sourcing `/etc/bash.bashrc` in your `$HOME/.bashrc` whilst using this image else you might not get binary paths pouplated as expected