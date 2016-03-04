#!/usr/bin/python3
# test percona-cluster (3 nodes)

import basic_deployment
import time


class ThreeNode(basic_deployment.BasicDeployment):
    def __init__(self):
        super(ThreeNode, self).__init__(units=3)

    def run(self):
        super(ThreeNode, self).run()
        # we are going to kill the master
        old_master = self.master_unit
        print('kill-9 mysqld in %s' % str(self.master_unit.info))
        self.master_unit.run('sudo killall -9 mysqld')

        print('looking for the new master')
        i = 0
        changed = False
        while i < 10 and not changed:
            i += 1
            time.sleep(5)  # give some time to pacemaker to react
            new_master = self.find_master()

            if (new_master and new_master.info['unit_name'] !=
                    old_master.info['unit_name']):
                changed = True

        assert changed, "The master didn't change"

        assert self.is_port_open(address=self.vip), 'cannot connect to vip'


if __name__ == "__main__":
    t = ThreeNode()
    t.run()
