From: Horms <horms@verge.net.au>
Date: Mon, 04 Sep 2006 06:23:25 +0000
Subject: NODE_DATA without CONFIG_NUMA
Message-Id: <20060904062323.GA9293@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm trying to build a non-NUMA (HP_SIM) config, and I am running
into trouble because there are serveral places where NODE_DATA is
used. It seems to me that this makes little sense as NODE_DATA
needs the node_data element of struct cpuinfo_ia64, which doesn't
exist without CONFIG_NUMA.

Is CONFIG_NUMA mandatory or is this just an oversight?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/


-- 
VGER BF report: U 0.500823
