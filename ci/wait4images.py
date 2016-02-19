#!/usr/bin/env python

import logging
import sys
import time



from maas_deployer.vmaas import (
    vm,
    util,
    template,
)
from maas_deployer.vmaas.exception import (
    MAASDeployerClientError,
    MAASDeployerConfigError,
    MAASDeployerValueError,
)
from maas_deployer.vmaas.maasclient import (
    bootimages,
    MAASClient,
    Tag,
)
from maas_deployer.vmaas.maasclient.driver import Response
from maas_deployer.vmaas.engine import DeploymentEngine
from maas_deployer.vmaas.util import CONF as cfg

log = logging.getLogger('vmaas.main')
handler = logging.StreamHandler()


def main():

        user="ubuntu"
        password="ubuntu"
        ip_addr="192.168.122.2"

        handler.setLevel(logging.DEBUG)
        checker = bootimages.ImageImportChecker(host=ip_addr,
                                                username=user,
                                                password=password)
        log.debug("Logging into %s", (ip_addr))
        checker.do_login()
        while not checker.did_downloads_start():
            log.debug("Waiting for downloads of boot images to start...")
            time.sleep(2)

        complete, status = checker.are_images_complete()
        while not complete:
            # Make sure to verify there are resources in the status query.
            # Its possible that the check comes in before MAAS determines
            # which resources it needs, etc
            if status.resources:
                status_str = status.resources[0].status
                sys.stdout.write(' Importing images ... %s ' % status_str)
                sys.stdout.flush()
                sys.stdout.write('\r')
            time.sleep(5)
            complete, status = checker.are_images_complete()

        log.debug("\r\nBoot image importing has completed.")




if __name__ == '__main__':
    main()
