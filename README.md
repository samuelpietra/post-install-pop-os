# About

Installs and sets up packages for Pop!\_OS (22.04 LTS or higher)

# Usage

Grant script execution privilege to user

```bash
chmod u+x post-install.sh
```

Then run the script normally

```bash
bash post-install.sh
```

# Known issues

- Very slow download for some packages. Mostly `flatpak` ones.
- There's a **@FIXME** to review `snap` package manager installation.
