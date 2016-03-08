#!/bin/bash
#placeholder for deployment script.
set -ex

case "$1" in
    'nonha' )
        cp nosdn/juju-deployer/ovs.yaml ./bundles.yaml
        ;;
    'ha' )
        cp nosdn/juju-deployer/ovs-ha.yaml ./bundles.yaml
        ;;
    'tip' )
        cp nosdn/juju-deployer/ovs-tip.yaml ./bundles.yaml
        cp common/source/* ./
        sed -i -- "s|branch: master|branch: stable/$2|g" ./*.yaml
        ;;
    * )
        cp nosdn/juju-deployer/ovs.yaml ./bundles.yaml
        ;;
esac

case "$3" in
    'orangepod2' )
        cp maas/orange/pod2/control-interfaces.host trusty/ubuntu-nodes-controller/network/interfaces.host
        cp maas/orange/pod2/lxc-add-more-interfaces trusty/ubuntu-nodes-controller/lxc/add-more-interfaces
        cp maas/orange/pod2/compute-interfaces.host trusty/ubuntu-nodes-compute/network/interfaces.host
        cp maas/orange/pod2/lxc-add-more-interfaces trusty/ubuntu-nodes-compute/lxc/add-more-interfaces
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/192.168.2.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 192.168.12.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth1"/g' ./bundles.yaml
         ;;
     'intelpod6' )
         cp maas/intel/pod6/interfaces.host trusty/ubuntu-nodes-controller/network/interfaces.host
         cp maas/intel/pod6/lxc-add-more-interfaces trusty/ubuntu-nodes-controller/lxc/add-more-interfaces
         cp maas/intel/pod6/interfaces.host trusty/ubuntu-nodes-compute/network/interfaces.host
         cp maas/intel/pod6/lxc-add-more-interfaces trusty/ubuntu-nodes-compute/lxc/add-more-interfaces
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/10.4.1.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 10.4.9.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "brPublic"/g' ./bundles.yaml
         ;;
     'intelpod5' )
         cp maas/intel/pod5/interfaces.host trusty/ubuntu-nodes-controller/network/interfaces.host
         cp maas/intel/pod5/lxc-add-more-interfaces trusty/ubuntu-nodes-controller/lxc/add-more-interfaces
         cp maas/intel/pod5/interfaces.host trusty/ubuntu-nodes-compute/network/interfaces.host
         cp maas/intel/pod5/lxc-add-more-interfaces trusty/ubuntu-nodes-compute/lxc/add-more-interfaces
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/10.4.1.2/g' ./bundles.yaml
        # choose the correct interface to use for data network
         sed -i -- 's/#os-data-network: 10.4.8.0\/21/os-data-network: 10.4.9.0\/24/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "brPublic"/g' ./bundles.yaml
        ;;
     'attvirpod1' )
         cp maas/att/virpod1/interfaces.host trusty/ubuntu-nodes-controller/network/interfaces.host
         cp maas/att/virpod1/interfaces.host trusty/ubuntu-nodes-compute/network/interfaces.host
         cp maas/att/virpod1/lxc-add-more-interfaces trusty/ubuntu-nodes-controller/lxc/add-more-interfaces
         cp maas/att/virpod1/lxc-add-more-interfaces trusty/ubuntu-nodes-compute/lxc/add-more-interfaces
        # As per your lab vip address list be deafult uses 10.4.1.11 - 10.4.1.20
         sed -i -- 's/10.4.1.1/192.168.10.1/g' ./bundles.yaml
        # Choose the external port to go out from gateway to use.
         sed -i -- 's/#        "ext-port": "eth1"/        "ext-port": "eth1"/g' ./bundles.yaml
        ;;
esac

echo "... Deployment Started ...."
case "$1" in
    'nonha' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes --local-mods
        juju-deployer -vW -d -c bundles.yaml trusty-"$2" --local-mods
        ;;
    'ha' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"
        ;;
    'tip' )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"
        ;;
    * )
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"-nodes
        juju-deployer -vW -d -c bundles.yaml trusty-"$2"
        ;;
esac

