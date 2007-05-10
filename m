From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 May 2007 10:19:45 +0000
Subject: [request-for-test] [patch 0/3] [IA64] Allow DISCONTIGMEM without NUMA
Message-Id: <20070510101945.495818588@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches relate to allowing DISCONTIG memory to compile
(and hopefully work) without NUMA. I've tested that they boot, but not much
beyond that.

The first two patches are minor cleanups in files related to this change.
The third patch is the real change.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

