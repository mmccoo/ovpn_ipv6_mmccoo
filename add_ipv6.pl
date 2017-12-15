#!/usr/bin/perl

use warnings;
use strict;
use File::Copy;

my $ifconf = `ifconfig -a`;

# here I get to main network interface (ens3, eth0...)
# as well as the ipv6/64 prefix
my $intf;
my $netprefix;
my $relevant;
foreach my $line (split(/\n/, $ifconf)) {
    #print($line, "\n");
    chomp $line;

    my ($intname) = ($line =~ /^([a-zA-Z0-9]+)/);
    if (defined($intname)) {
        $relevant = 0;
        
        if (grep(/tun|lo/, $intname)) { next; }
        
        if (defined($intf)) {
            printf("warning multiple interfaces found %s, %s\n", $intf, $intname);
            printf("assuming the first one found %s\n", $intf);
        } else {
            $intf = $intname;
            printf("found interface %s\n", $intf);
            $relevant = 1;
        }
    }

    # skip if I'm not in a relevant section. Ie not in a tun or lo
    # also skip if in a second interface.
    next unless ($relevant);
    
    
    my ($foundipv6) = ($line =~ /inet6 addr: ([0-9a-fA-F:]+)/);
    # I take the first one. There are usually
    # more, but the first one is the correct one on my machines.
    if (defined($foundipv6) && !defined($netprefix)) {
        my @foundipv6 = split(/:/, $foundipv6);
        $netprefix = join(":", @foundipv6[0..3]);
        printf("using ipv6 %s\n", $netprefix);
    }

}


if (-e "server.conf.preipv6") {
    print("server.conf.preipv6 already exists. Already ran this script?\n");
} else {
    copy("server.conf", "server.conf.preipv6");

    if (open(my $fp, ">>", "server.conf")) {
        printf($fp "server-ipv6 %s::/64\n",              $netprefix);
        printf($fp "push \"route-ipv6 %s:80::/112\"\n",  $netprefix);
        printf($fp "push \"dhcp6-option DNS %s:80::1\"", $netprefix);
        printf($fp "tun-ipv6\n");
        printf($fp "proto udp6\n");

        #https://community.openvpn.net/openvpn/wiki/IPv6
        # To redirect all Internet-bound traffic, use the current 
        # allocated public IP space like this:
        printf($fp "push \"route-ipv6 2000::/3\"\n");
        
        close($fp);
    } else {
        print("can't open server.conf.preipv6 for append\n");
    }
}


# in this section, I'm uncommenting AUTOSTART=all because otherwise,
# service openvpn restart doesn't actually restart openvpn.
# https://a20.net/bert/2016/09/27/openvpn-client-connection-not-started-on-ubuntu-16-04/
open(my $fp, "<", "/etc/default/openvpn") || die("can't open /etc/default/openvpn\n");
my @lines = readline($fp);
close($fp);

if (open(my $fp, ">", "openvpn")) {
    foreach my $line (@lines) {
        $line =~ s/#AUTOSTART="all"/AUTOSTART="all"/;
        print($fp $line);
    }
}
# reload systcl changes just made.
#system("systemctl daemon-reload");



# end
