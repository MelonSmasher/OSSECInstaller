# OSSEC Installer

## Usage

### Stable (2.9.0)

```shell
curl -sL https://raw.githubusercontent.com/MelonSmasher/OSSECInstaller/master/ossec-install.sh | bash -s -- -p "https://webserver.your.domain/preloaded-vars.conf"
```

### Old Stable (2.8.3)

```shell
curl -sL https://raw.githubusercontent.com/MelonSmasher/OSSECInstaller/master/ossec-install.sh | bash -s -- -o -p "/tmp/preloaded-vars.conf"
```

### Manually specify the version

```shell
curl -sL https://raw.githubusercontent.com/MelonSmasher/OSSECInstaller/master/ossec-install.sh | bash -s -- -v "2.7.1" -c "e9559aabe02baf92b15fe32c7e76f8541ba68aac7799ec7cbfd7c2d723d7fe38" -p "/tmp/preloaded-vars.conf"
```

#### Options:

* -s `Skip checksum verification... not recommended but it's here.`
* -o `Install the previous stable release instead of the current stable release.`
* -p `URL or local file path to the preloaded vars file that will be used.` This option is required.
* -f `Force install even if the version that is installed is the same as the target version.`
* -v `The version that should be installed. If suppled the '-c' option is required.` Versions can be found [here](https://github.com/ossec/ossec-hids/releases)
* -c `The sha256 checksum string of the target version that should be installed.` This option is required with the `-v` option.
