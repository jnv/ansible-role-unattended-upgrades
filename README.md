# [Unattended-Upgrades Role for Ansible](https://github.com/jnv/ansible-role-unattended-upgrades)

Install and setup [unattended-upgrades](https://launchpad.net/unattended-upgrades) for Ubuntu and Debian (since Wheezy), to periodically install security upgrades,

## Requirements

The role uses [apt module](http://docs.ansible.com/apt_repository_module.html) which has additional dependencies. You can use [bootstrap-debian](https://github.com/cederberg/ansible-bootstrap-debian) role to setup common Ansible requirements on Debian-based systems.

If you set `unattended_mail` to an e-mail address, make suer `mailx` command is available and your system is able to send e-mails.

## Role Variables

* `unattended_origins_patterns`: which origins patterns can be used to install upgrades, i.e. `o=Debian,a=stable` `.
  * Default: `[origin=Debian,archive=stable,label=Debian-Security]`
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

## Example

```yaml
- hosts: all
  roles:
  - role: jnv.unattended-upgrades
    unattended_allowed_origins: [origin=Debian,archive=stable,label=Debian-Security]
    unattended_package_blacklist: [cowsay, vim]
    unattended_mail: 'root@example.com'
```

## License

GPLv2
