#!/bin/bash
#placeholder for deployment script.
set -ex

case "$1" in
    'nonha' )
        cp odl/juju-deployer/ovs-odl.yaml ./bundles.yaml
        ;;
    'ha' )
        cp odl/juju-deployer/ovs-odl-ha.yaml ./bundles.yaml
        ;;
    'tip' )
        cp odl/juju-deployer/ovs-odl-tip.yaml ./bundles.yaml
        cp common/source/* ./
        sed -i -- "s|branch: master|branch: stable/$2|g" ./*.yaml
        ;;
    * )
        cp odl/juju-deployer/ovs-odl.yaml ./bundles.yaml
        ;;
esac

case "$3" in
    'orangepod2' )
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/192.168.2.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 192.168.12.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth1"/g' ./bundles.yaml
         ;;
     'intelpod6' )
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/10.4.1.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 10.4.9.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth2"/g' ./bundles.yaml
         ;;
     'intelpod5' )
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/10.4.1.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 10.4.9.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth2.724"/g' ./bundles.yaml
        ;;
     'attvirpod1' )
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/192.168.10.1/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth1"/g' ./bundles.yaml
        ;;
     'default' )
         sed -i -- 's/10.4.1.1/192.168.122.1/g' ./bundles.yaml
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth1"/g' ./bundles.yaml
        ;;
esac

echo "... Deployment Started ...."
case "$1" in
    'nonha' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -t 7200 -r 5 -c bundles.yaml trusty-"$2"
        ;;
    'ha' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -t 7200 -r 5 -c bundles.yaml trusty-"$2"
        ;;
    'tip' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -t 7200 -r 5 -c bundles.yaml trusty-"$2"
        ;;
    * )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -t 7200 -r 5 -c bundles.yaml trusty-"$2"
        ;;
esac

