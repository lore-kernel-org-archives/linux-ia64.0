From: dcn@sgi.com (Dean Nelson)
Date: Tue, 04 Apr 2006 14:03:01 +0000
Subject: [PATCH] eliminate compiler warning for xpc_channel.c
Message-Id: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Placate a compiler warning that 'msg' may be used uninitialized in
function xpc_initiate_allocate().

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-04-03 08:26:22.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-04-04 08:25:51.691831163 -0500
@@ -1831,7 +1831,7 @@
 {
 	struct xpc_partition *part = &xpc_partitions[partid];
 	enum xpc_retval ret = xpcUnknownReason;
-	struct xpc_msg *msg;
+	struct xpc_msg *msg = msg;
 
 
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);
