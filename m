From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 03 Feb 2004 18:57:28 +0000
Subject: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <20040203185728.GX13322@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="kfjH4zxOES6UT95V"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi David,

Can you please include this EXPORT_SYMBOL in the next release.  A few
macros that use physical_node_map are used in modules.

Thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="physical_node_map.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1542  -> 1.1543 
#	arch/ia64/sn/kernel/setup.c	1.28    -> 1.29   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/03	mort@green.i.bork.org	1.1543
# EXPORT_SYMBOL for physical_node_map.  This is required
# for some SN2 modules.
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Tue Feb  3 12:52:53 2004
+++ b/arch/ia64/sn/kernel/setup.c	Tue Feb  3 12:52:53 2004
@@ -70,6 +70,8 @@
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
+EXPORT_SYMBOL(physical_node_map);
+
 int     numionodes;
 
 /*

--kfjH4zxOES6UT95V--
