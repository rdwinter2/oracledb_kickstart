#!/usr/bin/perl
# file /usr/local/bin/ovfenv
# To insure this is only performed once at OVF deploy
#   log actions to /root/ovfenv.log
#   look for the log file
#   if the file is present then exit
# Before creating the ovf export make sure the log file isn't present
use warnings;
use strict;
# use Config::Simple;
# use Data::Dumper qw(Dumper);
use Digest::SHA qw(sha256_hex);

# export PERL5LIB=/home/ubuntu/workspace/postinstall/perl
# sudo /home/ubuntu/perl5/bin/cpanm Config::Simple
# sudo /home/ubuntu/perl5/bin/cpanm XML::Smart
# sysctl command for /etc/sysctl.conf

my %ovf;
my $hostname = `hostname -s`;
$hostname =~ s/\s+//g;
my $ovf = `/bin/vmtoolsd --cmd "info-get guestinfo.ovfenv"`;
my $file;
my $any_changes = 'no';
#my $old_sha256 = `/bin/vmtoolsd --cmd "info-get guestinfo.sha256"`;
#my $new_sha256 = sha256_hex($ovf);

#if ($old_sha256 eq $new_sha256) {
#  print "Configuration already performed\n";
#  exit;
#}

open my $fh, '<', \$ovf or die $!;
while (<$fh>) {
  chomp;
  if (/oe:key/) {
    my @a = split /=/;
    my @b = split /"/, $a[1];
    my @c = split /"/, $a[2];
    $ovf{$b[1]} = $c[1];
  }
}
close $fh;
my $ip = $ovf($hostname);

#foreach my $k (sort keys %ovf) {
#  print "$k -> $ovf{$k}\n";
#}

# my $cfg = new Config::Simple('ifcfg_eno');

# print $cfg->param("IPADDR") . "\n";
#$cfg->param("IPADDR", "10.10.40.78");
#$cfg->param("GATEWAY", "10.10.40.1");
#$cfg->param('DEFAULT.USER.IPV4', "true");
#$cfg->param("default.network.user.ip", "10.10.10.19");
#print $cfg->param("IPADDR") . "\n";
#$cfg->write();
#foreach ( @data ) {  # Verify
#    warn( "Parameter '$_' is missing from INI!\n" )
#      unless exists $config{$_};
#}

my @dns = split /,\s+/, $ovf(dns);
my @ntp = split /,\s+/, $ovf(ntp);
my $fqdn = "$ovf{hostname1}.$ovf{subdomain}.$ovf{domain}";
`hostnamectl set-hostname $fqdn`;

open my $fh, '>', '/etc/hosts';
print $fh <<"EOT";
127.0.0.1               localhost localhost.localdomain localhost4 localhost4.localdomain4
$ovf{ip1}             $ovf{hostname1} $ovf{hostname1}.$ovf{subdomain}.$ovf{domain}
$ovf{ip1}             $ovf{hostname2} $ovf{hostname2}.$ovf{subdomain}.$ovf{domain}
EOT
close $fh

open $fh, '>', '/etc/resolv.conf';
print $fh <<"EOT";
nameserver $ovf{dns1}
nameserver $ovf{dns2}
search $ovf{subdomain}.$ovf{domain} $ovf{domain}
options attempts:2
options timeout:1
EOT
close $fh
open ($fh, '>', '/etc/sysconfig/network');
print $fh <<"EOT";
NETWORKING=yes
HOSTNAME=$fqdn
DOMAIN=$ovf{subdomain}.$ovf{domain}
GATEWAY=$ovf{gateway}
NOZEROCONF=yes
EOT
close $fh
# `/bin/ls -d /sys/class/net/e* | sed -e 's/.*\///g'`
my $net = `ls -1 /sys/class/net | grep -ve 'lo'`;
$net =~ s/\n//g;
my $addr = `cat /sys/class/net/$net/address`;
my $uuid=`uuidgen $net`;
myifcfg = "/etc/sysconfig/network-scripts/ifcfg-$net";
open $fh, '>', $ifcfg;
print $fh <<"EOT";
NAME="$net"
DEVICE="$net"
HWADDR="$addr"
TYPE="Ethernet"
BOOTPROTO="static"
HOTPLUG="no"
DOMAIN="$ovf{domain}"
IPV6INIT="no"
IPV6_AUTOCONF="no"
IPV6_DEFROUTE="no"
IPV6_PEERDNS="no"
IPV6_PEERROUTES="no"
NETMASK="255.255.255.0"
ONBOOT="yes"
NM_CONTROLLED="no"
IPADDR0="$ovf{ip1}"
PREFIX0="24"
GATEWAY0="$ovf{gateway}"
DNS1="$ovf{dns1}"
DNS2="$ovf{dns2}"
PEERDNS="yes"
PEERROUTES="yes"
UUID="$uuid"
EOT
#firewall-cmd --zone=drop --add-interface=${i}
#firewall-cmd --reload
#file=/etc/chrony.conf
#/bin/sed -i -e '/^[#]*server /d' $file
#for j in ${ntp}; do
#  /bin/sed -i -e "2aserver ${j} iburst" $file
#done
# Add these line for improved leap smear when chrony is > 2.0
#/bin/cat <<- EOT >> /etc/chrony.conf
#leapsecmode slew
#maxslewrate 1000
#smoothtime 400 0.001 leaponly
#EOT
#/bin/systemctl restart chronyd
# timedatectl
# chronyc tracking


`/bin/vmtoolsd --cmd "info-get guestinfo.sha256 $new_sha256"`;