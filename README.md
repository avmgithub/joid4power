# joid4power
<H2>OPNFV Joid project for IBM OpenPOWER architecture</H2>

This is the OPNFV project for OpenPOWER. We will be using JOID from OPNFV.
For reference see https://wiki.opnfv.org/joid/get_started

**This document is still work in progress. Please be patient**

Requirements:
Ubuntu 14.04 ppc64el
Ubuntu KVM. Follow instructions : https://wiki.ubuntu.com/ppc64el/KVM1404

You may also want to install vncserver to be able to run firefox on 
the server to access MAAS on the maas VM.
Note: Download tightvncserver version 1.3.10-0ubuntu2 for ppc64el Ubuntu. 
Any version less than 1.3.10-2 does not work.
Follow instructions on:
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-14-04 or https://www.digitalocean.com/community/tutorials/how-to-setup-vnc-for-ubuntu-12

Download with:
git clone https://github.com/avmgithub/joid4power.git

cd joid4power/ci

Run the command
./02-maasdeploy.sh  virtinstall 2>&1 |tee my.log

The above command line does the following:

1) add repositories
2) download maas-deployer
3) apply patches to maas-deployer for specific OpenPOWER changes (this will not be needed once the patches get into the mainline)
4) Create opnfv-maas, bootstrap VMs
5) Deploy maas to opnfv-maas
6) Apply patches to maas for OpenPOWER specific changes (maas 1.9.1 should fix most if not all bugs in current maas version)
7) Reboot maasserver
8) Download specific OpenPOWER cloud images to maasserver
9) Deploy 2 more VMs, node1-controller and node2-compute.
10) Commission all VMs ready for deployment.

Note:
If something fails, before re-running the 02-maasdeploy.sh script, run the ./cleanup script



