# ovpn_ipv6_mmccoo


This repo holds the add_ipv6.pl script whose purpose is to take an existing openvpn server configuration and enable ipv6. 

My ISP gives me a ipv6 address, which is great but basic openvpn will not tunnel ipv6 traffic. It'll go to the target site directly. This is true for google.com, pandora.com,... lots (most?) of the sites out there


The script will hopefully become obsolete because it's a follow on to another script.

If you do the following on a fresh ubuntu 16.04 install:

    apt install -y openvpn easy-rsa emacs24 traceroute
    wget https://git.io/vpn -O openvpn-install.sh
    bash ./openvpn-install.sh
    
And answer the questions, you'll have a working openvpn for ipv4.

If you then run add_ipv6.pl from this repo, you'll hopefully have ipv6 traffic routed as well. Note that you need all of the files in the repo for it to work.

after running the script, be sure to do

    service openvpn restart
    
also restart your existing vpn connections.
