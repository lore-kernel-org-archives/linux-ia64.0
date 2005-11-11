From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 11 Nov 2005 22:52:02 +0000
Subject: [patch] bte_copy nasid_index fix
Message-Id: <200511112252.jABMq25h027789@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] bte_copy nasid_index fix

The nasid_index was not being incremented if the
pointer was null, causing an infinite loop.


Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/sn/kernel/bte.c |    1 +
 1 files changed, 1 insertion(+)

Index: test/arch/ia64/sn/kernel/bte.c
=================================--- test.orig/arch/ia64/sn/kernel/bte.c	2005-11-02 15:09:24.420194342 -0600
+++ test/arch/ia64/sn/kernel/bte.c	2005-11-11 13:47:34.180408880 -0600
@@ -137,6 +137,7 @@ retry_bteop:
 			bte = bte_if_on_node(nasid_to_try[nasid_index],bte_if_index);
 
 			if (bte = NULL) {
+				nasid_index++;
 				continue;
 			}
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
