#!/bin/bash
#placeholder for deployment script.
set -x

arch=$(uname -m)
virtinstall=0

if [ ${arch} == 'ppc64le' ];
then
    ppc64_cpu --smt=off
    ./cleanvm.sh
fi

case "$1" in
    'intelpod5' )
        cp maas/intel/pod5/deployment.yaml ./deployment.yaml
        ;;
    'intelpod6' )
        cp maas/intel/pod6/deployment.yaml ./deployment.yaml
        ;;
    'orangepod2' )
        cp maas/orange/pod2/deployment.yaml ./deployment.yaml
        ;;
    'attvirpod1' )
        cp maas/att/virpod1/deployment.yaml ./deployment.yaml
        ;;
    'juniperpod1' )
        cp maas/juniper/pod1/deployment.yaml ./deployment.yaml
        ;;
    * )
        virtinstall=1
        cp maas/default/deployment.yaml ./deployment.yaml
        ;;
esac

#make sure no password asked during the deployment. 

echo "$USER ALL=(ALL) NOPASSWD:ALL" > 90-joid-init

if [ -e /etc/sudoers.d/90-joid-init ]; then
    sudo cp /etc/sudoers.d/90-joid-init 91-joid-init
    cat 90-joid-init >> 91-joid-init
    sudo chown root:root 91-joid-init
    sudo mv 91-joid-init /etc/sudoers.d/
else
    sudo chown root:root 90-joid-init
    sudo mv 90-joid-init /etc/sudoers.d/
fi

echo "... Deployment of maas Started ...."

if [ ! -e $HOME/.ssh/id_rsa ]; then
    ssh-keygen -N '' -f $HOME/.ssh/id_rsa
fi

if [ ! -e /var/lib/libvirt/images ]; then

    sudo apt-get install libvirt-bin -y
    sudo adduser ubuntu libvirtd
    sudo virsh pool-define-as default --type dir --target /var/lib/libvirt/images/
    sudo virsh pool-start default
    sudo virsh pool-autostart default

fi

sudo apt-add-repository ppa:maas-deployers/stable -y
sudo apt-add-repository ppa:juju/stable -y
sudo apt-add-repository ppa:maas/stable -y
sudo apt-get update -y

if [ ${arch} == 'ppc64le' ];
then
    sudo apt-get install maas-deployer=0.0.5-0ubuntu0 -y
    ./apply_maas_patch.sh
    sudo apt-get install openssh-server git juju juju-deployer maas-cli python-pip -y
else
    sudo apt-get install openssh-server git maas-deployer juju juju-deployer maas-cli python-pip -y
fi

sudo pip install shyaml
juju init -f

cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

if [ "$virtinstall" -eq 1 ]; then
    sudo virsh net-dumpxml default > default-net-org.xml
    sudo sed -i '/dhcp/d' default-net-org.xml
    sudo sed -i '/range/d' default-net-org.xml
    sudo virsh net-define default-net-org.xml
    sudo virsh net-destroy default
    sudo virsh net-start default
fi

#Below function will mark the interfaces in Auto mode to enbled by MAAS
enableautomode() {
    listofnodes=`maas maas nodes list | grep system_id | cut -d '"' -f 4`
    for nodes in $listofnodes
    do
        maas maas interface link-subnet $nodes $1  mode=$2 subnet=$3
    done
}

#Below function will mark the interfaces in Auto mode to enbled by MAAS
# using hostname of the node added into MAAS

enableautomodebyname() {
    if [ ! -z "$4" ]; then
        for i in `seq 1 7`;
        do
            nodes=`maas maas nodes list hostname=node$i-$4 | grep system_id | cut -d '"' -f 4`
            if [ ! -z "$nodes" ]; then
                maas maas interface link-subnet $nodes $1  mode=$2 subnet=$3
            fi
       done
    fi
}

#Below function will create vlan and update interface with the new vlan
# will return the vlan id created
crvlanupdsubnet() {
    newvlanid=`maas maas vlans create $2 name=$3 vid=$4 | grep resource | cut -d '/' -f 6 `
    maas maas subnet update $5 vlan=$newvlanid
    eval "$1"="'$newvlanid'"
}

#Below function will create interface with new vlan and bind to physical interface
crnodevlanint() {
    listofnodes=`maas maas nodes list | grep system_id | cut -d '"' -f 4`

    for nodes in $listofnodes
    do
        parentid=`maas maas interface read $nodes eth2 | grep interfaces | cut -d '/' -f 8`
        maas maas interfaces create-vlan $nodes vlan=$1 parent=$parentid
     done
 }

sudo maas-deployer -c deployment.yaml -d --force

sudo chown $USER:$USER environments.yaml

echo "... Deployment of maas finish ...."

if [ ${arch} == 'ppc64le' ];
then
    echo "...Patching maas for POWER ...."
    ./install_curtin_packages
    scp -r -i /root/.ssh/id_maas -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  maasserver_patches ubuntu@192.168.122.2:/tmp
    ssh -i /root/.ssh/id_maas -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@192.168.122.2 "cd /tmp/maasserver_patches; sudo ./maasserver_patches.sh"
fi


maas_ip=`grep " ip_address" deployment.yaml | cut -d " "  -f 10`
apikey=`grep maas-oauth: environments.yaml | cut -d "'" -f 2`
maas login maas http://${maas_ip}/MAAS/api/1.0 ${apikey}
maas maas boot-source update 1 url="http://maas.ubuntu.com/images/ephemeral-v2/daily/"
#maas maas boot-source-selections create 1 os="ubuntu" release="precise" arches="amd64" subarches="*" labels="*"
maas maas boot-resources import

maas maas sshkeys new key="`cat $HOME/.ssh/id_rsa.pub`"

if [ ${arch} == 'ppc64le' ];
then
   ./ppc64
fi

#adding compute and control nodes VM to MAAS for deployment purpose.
if [ "$virtinstall" -eq 1 ]; then
    # create two more VMs to do the deployment.
    sudo virt-install --connect qemu:///system --name node1-control --ram 8192 --vcpus 4 --video vga --arch ppc64 --disk size=120,format=qcow2,bus=virtio,io=native,pool=default --network bridge=virbr0,model=virtio --network bridge=virbr0,model=virtio --boot network,hd,menu=off --noautoconsole --vnc --print-xml | tee node1-control

    sudo virt-install --connect qemu:///system --name node2-compute --ram 8192 --vcpus 4 --video vga --arch ppc64 --disk size=120,format=qcow2,bus=virtio,io=native,pool=default --network bridge=virbr0,model=virtio --network bridge=virbr0,model=virtio --boot network,hd,menu=off --noautoconsole --vnc --print-xml | tee node2-compute

    node1controlmac=`grep  "mac address" node1-control | head -1 | cut -d "'" -f 2`
    node2computemac=`grep  "mac address" node2-compute | head -1 | cut -d "'" -f 2`

    sudo virsh -c qemu:///system define --file node1-control
    sudo virsh -c qemu:///system define --file node2-compute

    maas maas tags new name='control'
    maas maas tags new name='compute'

    controlnodeid=`maas maas nodes new autodetect_nodegroup='yes' name='node1-control' tags='control' hostname='node1-control' power_type='virsh' mac_addresses=$node1controlmac power_parameters_power_address='qemu+ssh://'$USER'@192.168.122.1/system' architecture='ppc64el' power_parameters_power_id='node1-control' | grep system_id | cut -d '"' -f 4 `

    maas maas tag update-nodes control add=$controlnodeid

    computenodeid=`maas maas nodes new autodetect_nodegroup='yes' name='node2-compute' tags='compute' hostname='node2-compute' power_type='virsh' mac_addresses=$node2computemac power_parameters_power_address='qemu+ssh://'$USER'@192.168.122.1/system' architecture='ppc64el' power_parameters_power_id='node2-compute' | grep system_id | cut -d '"' -f 4 `

    maas maas tag update-nodes compute add=$computenodeid

fi

# Enable vlan interfaces with maas
case "$1" in
    'intelpod5' )
        maas refresh
        crvlanupdsubnet vlan721 1 "DataNetwork" 721 2 || true
        crvlanupdsubnet vlan724 2 "PublicNetwork" 724 3 || true
        crnodevlanint $vlan721 || true
        crnodevlanint $vlan724 || true
        enableautomodebyname eth1.721 AUTO "10.4.9.0/24" compute || true
        enableautomodebyname eth1.721 AUTO "10.4.9.0/24" control || true
        ;;
    'intelpod6' )
        maas refresh
        enableautomodebyname eth1 AUTO "10.4.9.0/24" compute || true
        enableautomodebyname eth1 AUTO "10.4.9.0/24" control || true
        ;;
    'orangepod2' )
        maas refresh
        enableautomodebyname eth4 AUTO "192.168.22.0/24" compute || true
        enableautomodebyname eth5 AUTO "192.168.12.0/24" compute || true
        enableautomodebyname eth2 AUTO "192.168.22.0/24" control || true
        enableautomodebyname eth3 AUTO "192.168.12.0/24" control || true
        ;;
    'attvirpod1' )
        ;;
    'juniperpod1' )
        ;;
esac

if [ ${arch} == 'ppc64le' ];
then
    ./update_maas_ppc64
fi

echo " .... MAAS deployment finished successfully ...."

#echo "... Deployment of opnfv release Started ...."
#python deploy.py $maas_ip

