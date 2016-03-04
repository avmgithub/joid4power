#!/usr/bin/env python
# test percona-cluster (1 node)
import basic_deployment


class SingleNode(basic_deployment.BasicDeployment):
    def __init__(self):
        super(SingleNode, self).__init__(units=1)

    def run(self):
        super(SingleNode, self).run()
        assert self.is_pxc_bootstrapped(), "Cluster not bootstrapped"


if __name__ == "__main__":
    t = SingleNode()
    t.run()
