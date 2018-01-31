# oracledb_kickstart
EL7 kickstart file for an Oracle database server.

The root account is locked, use admin and sudo.

kernel is set for 
* transparent_hugepage=never
* hugepages=


Follows the pratices outlined in [RedHatGov/ssg-el7-kickstart](https://github.com/RedHatGov/ssg-el7-kickstart) to build a EL7 server machine for an Oracle database install.

Files from the above repo, [Latest commit 4c8d996 on Oct 15, 2017](https://github.com/RedHatGov/ssg-el7-kickstart/commit/4c8d9968f4b95cae216a0b71e459609160d6857a), duplicated in this repo:
* ssg-suplemental.sh
* ipa-pam-configuration.sh

