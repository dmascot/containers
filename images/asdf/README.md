# asdf Container

An Alpine-based `asdf` container intended to be used as a development tool to enable quick and easy installation of tools.

## Features

- Provides `asdf_install` command:  
  Reads `.tool-versions` from the user's `$HOME` and installs missing plugins and tools with specified versions.
- Provides `verify_asdf` command:  
  Prints the installed `asdf` version.
- Provides `${ASDF_RC}` environment variable:  
  Points to `/etc/profile.d/asdfrc.sh`, which can be sourced to:
  - Set binary paths
  - Load helper functions for `asdf`

---

## How to Use

1. **Always source the ASDF environment before using:**

    ```bash
    . "${ASDF_RC}"
    ```

2. **Ensure `.tool-versions` file exists in your `$HOME` directory:**

    Example:

    ```bash
    cp /path/to/your/.tool-versions $HOME/
    ```

3. **Install the tools listed in `.tool-versions`:**

    ```bash
    asdf_install
    ```

4. **Verify `asdf` installation:**

    ```bash
    verify_asdf
    ```

5. **Customize further as needed.**

---

## Notes

- Use the latest version of this image when writing your `Dockerfile`.
- Install necessary build dependencies (`build-deps`) before running `asdf_install`.
- `.tool-versions` controls what gets installed.  
  Example content:

    ```
    python 3.12.2
    nodejs 20.10.0
    ```

---

## TODO

- [ ] Write tests to ensure `asdf` is installed
- [ ] Write tests to ensure `asdf` version shows correctly
- [ ] Write tests for `asdf_install`:
    - Should show informative error if `$HOME/.tool-versions` is missing
    - Should install specified plugins and versions
    - Should ensure `asdf` binaries are correctly added to `$PATH`
- [ ] Write tests for `source_asdf_scripts`:
    - Ensure binary paths are added to `$HOME/.bashrc` when sourced

---