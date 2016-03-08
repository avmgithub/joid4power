#!/bin/bash
set -x

turn_off_smt() {
    ppc64_cpu --smt=off
}

apply_maas_deployer_patches() {
    sudo apt-get install maas-deployer=0.0.6-0ubuntu0.1 -y
    ./apply_maas_patch.sh
    sudo apt-get install openssh-server git juju juju-deployer maas-cli python-pip -y
}

download_ppc64_images() {
   maas_ip=`grep " ip_address" deployment.yaml | cut -d " "  -f 10`
   ssh -i /root/.ssh/id_maas -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${maas_ip} "sudo service maas-regiond restart; sudo service maas-clusterd restart"
   sleep 60
   ./ppc64
   ./wait4images.py
   sleep 60
}

update_maas_ppc64() {
    maas_ip=`grep " ip_address" deployment.yaml | cut -d " "  -f 10`
    qemu_uri=`grep qemu deployment.yaml  | awk '{print $2}'`
    ./update_maas_ppc64 ${qemu_uri}
}

case "$1" in
    'turn_off_smt' )
        turn_off_smt
        ;;
    'apply_maas_deployer_patches' )
        apply_maas_deployer_patches
        ;;
    'download_ppc64_images' )
        download_ppc64_images
        ;;
    'update_maas_ppc64' )
        update_maas_ppc64
        ;;
    * )
        ;;
esac
