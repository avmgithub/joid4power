#!/usr/bin/env python

import logging
import sys
import time
import yaml
import os

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
        
        cfg.parser.add_argument('-c', '--config', type=str,
                            default='deployment.yaml', required=False)
        cfg.parser.add_argument('target', metavar='target', type=str, nargs='?',
                            help='Target environment to run')

        cfg.parse_args()
        if not os.path.isfile(cfg.config):
            log.error("Unable to find config file %s", cfg.config)
            sys.exit(1)

        with open(cfg.config, 'r') as fd:
            config = yaml.safe_load(fd)

        target = cfg.target

        if target is None and len(config.keys()) == 1:
            target = config.keys()[0]

        if target not in config:
            log.error("Unable to find target: %s", target)
            sys.exit(2)

        config1 = config.get(target)

        maas_config = config1.get('maas')

        user = maas_config['user']
        password = maas_config['password']
        ip_addr = maas_config['ip_address']

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
