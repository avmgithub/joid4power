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
   sleep 60
   maas maas boot-source-selection update 1 1 os=ubuntu release=trusty arches=ppc64el arches=amd64 subarches=hwe-v subarches=hwe-w 'labels=*'

   sleep 20

   maas maas boot-resources import
   # get the value of id
   id="$(maas maas boot-sources read | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["id"]')"

   # find which has ppc64 boot selection
   num_sources="$(maas maas boot-resources read | python -c 'import json,sys;obj=json.load(sys.stdin);print len(obj[0])')"

   #echo $num_sources
   let num_sources=$num_sources+1
   #echo  $num_sources
   for i in `seq 1 $num_sources`
   do
       maas maas boot-resource read $i | grep ppc64 > /dev/null
       if [ $? -eq 0 ]
       then
         while true; do
            maas maas boot-resource read $i  | grep complete | grep false> /dev/null
            if [ $? -eq 1 ]; then
                break
            fi
            sleep 2
            echo -n "."
          done
       fi
   done
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
