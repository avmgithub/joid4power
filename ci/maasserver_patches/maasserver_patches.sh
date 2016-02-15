#!/bin/bash

ORG_DIR=`pwd`
cp patch1 /usr/lib/python2.7/dist-packages/provisioningserver/boot
cp patch2 /usr/lib/python2.7/dist-packages/provisioningserver/boot
cd /usr/lib/python2.7/dist-packages/provisioningserver/boot
patch < patch1
patch < patch2
cd $ORG_DIR

cp patch3 /usr/lib/python2.7/dist-packages/maasserver
cp patch4 /usr/lib/python2.7/dist-packages/maasserver
cd /usr/lib/python2.7/dist-packages/maasserver
patch < patch3
patch < patch4
cd $ORG_DIR


cp patch5 /usr/lib/python2.7/dist-packages/maasserver/models
cp patch6 /usr/lib/python2.7/dist-packages/maasserver/models
cd /usr/lib/python2.7/dist-packages/maasserver/models
patch < patch5
patch < patch6
cd $ORG_DIR
