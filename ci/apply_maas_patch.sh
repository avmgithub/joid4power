#!/bin/bash

CI_HOME=`pwd`

cp patch1.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
cp patch3.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
cp patch2.txt /usr/lib/python2.7/dist-packages/maas_deployer/vmaas/templates

cd /usr/lib/python2.7/dist-packages/maas_deployer/vmaas
patch < patch1.txt
patch < patch3.txt
cd /usr/lib/python2.7/dist-packages/maas_deployer/vmaas/templates
patch < patch2.txt
cd $CI_HOME
