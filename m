From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 May 2007 10:19:47 +0000
Subject: [request-for-test] [patch 2/3] Dont include asm-ia64/percpu.h in asm-ia64/nodedata.h
Message-Id: <20070510102033.157451957@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nothing in nodedata.h seems to need anything from percpu.h.
Perhaps this breaks things indirectly, but I didn't see anything in the
few tests that I ran.

From: Simon Horman <horms@verge.net.au>

Index: linux-2.6/include/asm-ia64/nodedata.h
=================================--- linux-2.6.orig/include/asm-ia64/nodedata.h	2007-05-10 19:00:01.000000000 +0900
+++ linux-2.6/include/asm-ia64/nodedata.h	2007-05-10 19:00:03.000000000 +0900
@@ -13,7 +13,6 @@
 
 #include <linux/numa.h>
 
-#include <asm/percpu.h>
 #include <asm/mmzone.h>
 
 #ifdef CONFIG_NUMA

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

