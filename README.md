# oracledb_kickstart

This role will build a kickstart of an EL7 host for an Oracle database installation.

The root account is locked, use admin and sudo.

kernel is set for 
* transparent_hugepage=never
* hugepages=


Follows the pratices outlined in [RedHatGov/ssg-el7-kickstart](https://github.com/RedHatGov/ssg-el7-kickstart) to build a EL7 server machine for an Oracle database install.

Files from the above repo, [Latest commit 4c8d996 on Oct 15, 2017](https://github.com/RedHatGov/ssg-el7-kickstart/commit/4c8d9968f4b95cae216a0b71e459609160d6857a), duplicated in this repo:
* ssg-suplemental.sh
* ipa-pam-configuration.sh

## Example Playbook

	- name: PLAY | kickstart host install for Oracle database install
	  hosts: [pxeboot]
	  become: true
	  become_method: 'sudo'
	  roles:
	    - { role: oracledb_kickstart }

## License

MIT

## Author Information

|Author|E-mail|
|---|---|
|Bob Winter|TBD|

## References
