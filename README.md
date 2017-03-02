# OSSEC Client Installer

## Usage

### Stable (2.9.0)

```shell
curl -sL https://raw.githubusercontent.com/MelonSmasher/OSSECInstaller/master/ossec-install.sh | bash -s -- -p "https://webserver.your.domain/preloaded-vars.conf"
```

### Old Stable (2.8.3)

```shell
curl -sL https://raw.githubusercontent.com/MelonSmasher/OSSECInstaller/master/ossec-install.sh | bash -s -- -o -p "https://webserver.your.domain/preloaded-vars.conf"
```

#### Options:

* -o `Install the previous stable release instead of the current stable release.`
* -p `URL to the preloaded vars file that will be used.` This option is required.
