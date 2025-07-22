----- PANEL CONFIGURATION, MODIFIED VERSION --------

## Usage
To run the automated installer use `curl` piped into `bash` as root. Piping avoids problems with `/dev/fd` that can appear when using process substitution.

```bash
curl -s https://raw.githubusercontent.com/HyHamza/SERVER-CONFIG/refs/heads/main/auto_install.sh | sudo bash
```

The script requires root privileges and will download the necessary installer components.
