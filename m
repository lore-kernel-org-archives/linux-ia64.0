From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 23 Jan 2004 18:45:38 +0000
Subject: [PATCH] arch/ia64/sn/kernel/sn2/cache.c missing a #include
Message-Id: <20040123184537.GN15871@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IuhbYIxU28t+Kd57"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--IuhbYIxU28t+Kd57
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi David,

Here is a small patch which adds a missing #include

thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--IuhbYIxU28t+Kd57
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-cache-export-symbol.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1498  -> 1.1499 
#	arch/ia64/sn/kernel/sn2/cache.c	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/23	mort@green.i.bork.org	1.1499
# Get rid of this warning:
# 
# arch/ia64/sn/kernel/sn2/cache.c:34: warning: type defaults to `int' in declaration of `EXPORT_SYMBOL'
# arch/ia64/sn/kernel/sn2/cache.c:34: warning: parameter names (without types) in function declaration
# arch/ia64/sn/kernel/sn2/cache.c:34: warning: data definition has no type or storage class
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/sn2/cache.c b/arch/ia64/sn/kernel/sn2/cache.c
--- a/arch/ia64/sn/kernel/sn2/cache.c	Fri Jan 23 09:42:15 2004
+++ b/arch/ia64/sn/kernel/sn2/cache.c	Fri Jan 23 09:42:15 2004
@@ -7,6 +7,7 @@
  *
  */
 
+#include <linux/module.h>
 #include <asm/pgalloc.h>
 
 /**

--IuhbYIxU28t+Kd57--
