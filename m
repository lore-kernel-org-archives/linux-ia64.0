From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 27 Oct 2003 22:17:13 +0000
Subject: Compilation fix for UP I2000
Message-Id: <marc-linux-ia64-106729391426813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	The variable `foo' was deleted in a recent changeset, but one
reference was missed.  I needed the appended patch to get a good
compilation for uniprocessor I2000.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1370  -> 1.1371 
#	arch/ia64/kernel/perfmon.c	1.65    -> 1.66   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/28	peterc@gelato.unsw.edu.au	1.1371
# [IA64] delete reference to deleted variable `foo' in perfmon.c
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Tue Oct 28 09:16:50 2003
+++ b/arch/ia64/kernel/perfmon.c	Tue Oct 28 09:16:50 2003
@@ -5787,8 +5787,6 @@
 	 */
 	psr = pfm_get_psr();
 
-	BUG_ON(foo & (IA64_PSR_I));
-
 	/*
 	 * stop monitoring:
 	 * This is the last instruction which may generate an overflow
