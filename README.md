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

Edit the maas/default/deployment.yaml file according to your environment. You can copy the maas/default/deployment.yaml.POWER example to maas/default/deployment.yaml and modify to your environment.

Run the command
./02-maasdeploy.sh  virtinstall 2>&1 |tee my.log

The above command line does the following:

1. add repositories to to your local server
2. download maas-deployer package
3. apply patches to maas-deployer for specific OpenPOWER changes (this will not be needed once the patches get into the mainline)
4. Create opnfv-maas, bootstrap VMs
5. Deploy maas to opnfv-maas
7. Download specific OpenPOWER cloud images to maasserver
8. Deploy 2 more VMs, node1-controller and node2-compute.
9. Commission all VMs ready for deployment.

This may take several minutes depending on your network connection for downloading images
Check the MAAS URL http://<maas IP>/MAAS.  Login ubuntu/ubuntu

Note:
If something fails, before re-running the 02-maasdeploy.sh script, run the ./cleanup script

Once the ./02-maasdeploy.sh script finishes you should have a MAAS deployed with 3 VMs (bootstrap, node1-controller and node2-compute).  Proceed to install Juju.

Installing Juju

#cp environments.yaml ~/.juju/
#rm /root/.juju/environments/*
#./00-bootstrap.sh

Once this finishes check the Juju URL  https://<bootstrap VM IP>/   Login: admin/<password from /root/.juju/environments/demo-maas file

For Openstack deployment run:
#./01-deploybundle.sh nonha liberty default
