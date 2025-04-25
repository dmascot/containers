# asdf container

This is Alpine based `asdf` conatiner intended to be used as a development tool to enable quick and easy installation of the tools 
it also provides 
- `asdf_install` command which can read `.tool-versions` from users `$HOME` and install missing plugin and tool with specified version
- `source_asdf_scripts` to set up asdf binay paths, asdf completions and asdf_helper commands

# Todo
Write test to ensure
- asdf is installed
- asdf version shows
- `asdf_install` tests
  - shows informative error if `$HOME/.tool-versions` file is missing
  - install actual plugin and its version
  - asdf binary paths are in `$PATH`
- `source_asdf_scripts` tests
  - binary paths are installed in `$HOME/.bashrc` when 
    
### Notes
1. ensure you are always sourcing `/etc/bash.bashrc` in your `$HOME/.bashrc` whilst using this image else you might not get binary paths pouplated as expected.
   you can simply use `source_asdf_scripts` command to achive this