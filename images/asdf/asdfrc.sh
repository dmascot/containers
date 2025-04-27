#!/usr/bin/env bash

# Only source if the function "asdf_install" is NOT already available
if ! command -v asdf_install &>/dev/null; then
  if [ -f /usr/local/share/asdf_helper ]; then
    . /usr/local/share/asdf_helper
  fi
fi

# Only export PATH if not already added
case ":$PATH:" in
  *":${HOME}/bin:"*) :;; # already present, do nothing
  *) export PATH="${HOME}/.asdf/bin:${PATH}";;
esac

case ":$PATH:" in
  *":${HOME}/shims:"*) :;; # already present, do nothing
  *) export PATH="${HOME}/.asdf/shims:${PATH}";;
esac