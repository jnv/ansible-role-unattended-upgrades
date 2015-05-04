# Unattended-Upgrades Role for Ansible

[![Build Status](https://travis-ci.org/jnv/ansible-role-unattended-upgrades.svg?branch=master)](https://travis-ci.org/jnv/ansible-role-unattended-upgrades)

Install and setup [unattended-upgrades](https://launchpad.net/unattended-upgrades) for Ubuntu and Debian (since Wheezy), to periodically install security upgrades.

**NOTE:** If you have used version 0.0.1 of the role, you can delete the file `/etc/apt/apt.conf.d/10periodic` as it is not needed anymore. You can use the following one-shot command:

    ansible -m file -a "state=absent path=/etc/apt/apt.conf.d/10periodic" <host-pattern>

## Requirements

The role uses [apt module](http://docs.ansible.com/apt_repository_module.html) which has additional dependencies. You can use [bootstrap-debian](https://github.com/cederberg/ansible-bootstrap-debian) role to setup common Ansible requirements on Debian-based systems.

If you set `unattended_mail` to an e-mail address, make sure `mailx` command is available and your system is able to send e-mails.

The role requires unattended-upgrades version 0.70 and newer, which is available since Debian Wheezy and Ubuntu 12.04 respectively. This is due to [Origins Patterns](#origins-patterns) usage; if this is not available on your system, you may use [the first version of the role](https://github.com/jnv/ansible-role-unattended-upgrades/tree/v0.1).

### Automatic Reboot

If you enable automatic reboot feature (`unattended_automatic_reboot`), the role will install `update-notifier-common` package, which is required for detecting and executing reboot after the upgrade.

**NOTE:** This feature is not currently supported on Debian Jessie, due to a missing replacement for the said package. Attempt to enable this feature on unsupported system will cause a failure. See [the discussion in #6](https://github.com/jnv/ansible-role-unattended-upgrades/issues/6) for more details.

## Role Variables

* `unattended_origins_patterns`: array of origins patterns to determine whether the package can be automatically installed, for more details see [Origins Patterns](#origins-patterns) below.
    * Default for Debian: `['origin=Debian,archive=${distro_codename},label=Debian-Security']`
    * Default for Ubuntu: `['origin=Ubuntu,archive=${distro_codename}-security,label=Ubuntu']`
* `unattended_package_blacklist`: packages which won't be automatically upgraded
    * Default: `[]`
* `unattended_autofix_interrupted_dpkg`: whether on unclean dpkg exit to run `dpkg --force-confold --configure -a`
    * Default: `true`
* `unattended_minimal_steps`: split the upgrade into the smallest possible chunks so that they can be interrupted with SIGUSR1.
    * Default: `false`
* `unattended_install_on_shutdown`: install all unattended-upgrades when the machine is shuting down.
    * Default: `false`
* `unattended_mail`: e-mail address to send information about upgrades or problems with unattended upgrades
    * Default: `false` (don't send any e-mail)
* `unattended_mail_only_on_error`: send e-mail only on errors, otherwise e-mail will be sent every time there's a package upgrade.
    * Default: `false`
* `unattended_remove_unused_dependencies`: do automatic removal of new unused dependencies after the upgrade.
    * Default: `false`
* `unattended_automatic_reboot`: Automatically reboot system if any upgraded package requires it, immediately after the upgrade.
    * Default: `false`


## Origins Patterns

Origins Pattern is a more powerful alternative to the Allowed Origins option used in previous versions of unattended-upgrade.

Pattern is composed from specific keywords:

* `a`,`archive`,`suite` – e.g. `stable`, `trusty-security` (`archive=stable`)
* `c`,`component`   – e.g. `main`, `crontrib`, `non-free` (`component=main`)
* `l`,`label` – e.g. `Debian`, `Debian-Security`, `Ubuntu`
* `o`,`origin` – e.g. `Debian`, `Unofficial Multimedia Packages`, `Ubuntu`
* `n`,`codename` – e.g. `jessie`, `jessie-updates`, `trusty`
* `site` – e.g. `http.debian.net`

You can review the available repositories using `apt-cache policy` and debug your choice using `unattended-upgrades -d` command on a target system.

Additionaly unattended-upgrades support two macros (variables), derived from `/etc/debian_version`:

* `${distro_id}` – Installed distribution name, e.g. `Debian` or `Ubuntu`.
* `${distro_codename}` – Installed codename, e.g. `jessie` or `trusty`.

## Role Usage Example

```yaml
- hosts: all
  roles:
  - role: jnv.unattended-upgrades
    unattended_origins_patterns:
    - 'origin=Ubuntu,archive=${distro_codename}-security'
    - 'o=Ubuntu,a=${distro_codename}-updates'
    unattended_package_blacklist: [cowsay, vim]
    unattended_mail: 'root@example.com'
```


### Patterns Examples

By default, only security updates are allowed for both Ubuntu and Debian. You can add more patterns to allow unattended-updates install more packages automatically, however be aware that automated major updates may potentially break your system.

#### For Debian

```yaml
# Archive based matching
unattended_origins_patterns:
  - 'origin=Debian,archive=${distro_codename},label=Debian-Security' # resolves to archive=jessie
  - 'o=Debian,a=stable'
  - 'o=Debian,a=stable-updates'
  - 'o=Debian,a=proposed-updates'
```

#### For Ubuntu

In Ubuntu, archive always contains the distribution codename

```yaml
unattended_origins_patterns:
  - 'origin=Ubuntu,archive=${distro_codename}-security'
  - 'o=Ubuntu,a=${distro_codename}'
  - 'o=Ubuntu,a=${distro_codename}-updates'
  - 'o=Ubuntu,a=${distro_codename}-proposed-updates'
```

## License

GPLv2
