# joid4power
<H2>OPNFV Joid project for IBM OpenPOWER architecture</H2>

This is the OPNFV project for OpenPOWER. We will be using JOID from OPNFV.
For reference see https://wiki.opnfv.org/joid/get_started

This document is still work in progress. Please be patient

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

You may get some errors on your first run because some files for the 
maas-deployer package may not have been patched yet.  See patch1.txt,
patch2.txt and patch3.txt

They have to be applied to the following files:

```
/usr/lib/python2.7/dist-packages/maas_deployer/vmaas/vm.py 
/usr/lib/python2.7/dist-packages/maas_deployer/vmaas/engine.py 
/usr/lib/python2.7/dist-packages/maas_deployer/vmaas/templates/cloud-init.cfg
```
```
cp patch1.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
cp patch3.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
cp patch2.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas/templates
```
```
cd /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
patch < patch1.txt
patch < patch3.txt
cd /usr/lib/python2.7/dist-packages/maas_deployer/vmaas/templates
patch < patch2.txt
```
