From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 09 Jun 2003 17:29:23 +0000
Subject: [Linux-ia64] [PATCH] Compile fix for perfmon 2
Message-Id: <marc-linux-ia64-105590723706197@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane and David,

Here is a little patch to fix compilation of perfmon 2 when it
is turned off.

thanks
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1125  -> 1.1126 
#	arch/ia64/kernel/perfmon.c	1.47    -> 1.48   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/09	mort@green.i.bork.org	1.1126
# Fix for the new perfmon in the case where it is turned off.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Mon Jun  9 13:27:15 2003
+++ b/arch/ia64/kernel/perfmon.c	Mon Jun  9 13:27:15 2003
@@ -6503,7 +6503,7 @@
 
 #else /* !CONFIG_PERFMON */
 asmlinkage long
-sys_perfmonctl (pfm_ctxid_t ctxid, int cmd, void *req, int count, long arg5, long arg6,
+sys_perfmonctl (int fd, int cmd, void *req, int count, long arg5, long arg6,
 		long arg7, long arg8, long stack)
 {
 	return -ENOSYS;

