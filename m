From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 05:03:35 +0000
Subject: [patch] Use srlz.d instead of srlz.i in ia64_leave_syscall
Message-Id: <200501190503.j0J53Zws002454@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Good for another 11+ cycle improvement in the syscall path.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 18:20:07-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Use srlz.d instead of srlz.i.  Safe because we don't care whether
#   	the VHPT walker sees the clearing of PSR.ic (if it does, that's fine
#   	if it doesn't, it's OK too since the kernel-text is pinned anyhow).
#   	Good for another 11+ cycles in (normal) getpid().
# 
# arch/ia64/kernel/entry.S
#   2005/01/18 18:19:55-08:00 davidm@tiger.hpl.hp.com +1 -1
#   (ia64_leave_syscall): Use srlz.d instead of srlz.i.
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 21:02:25 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 21:02:25 -08:00
@@ -749,7 +749,7 @@
 	ld8.fill r1=[r3],16	// load r1
 (pUStk) mov r17=1
 	;;
-	srlz.i			// M0  ensure interruption collection is off
+	srlz.d			// M0  ensure interruption collection is off
 	ld8.fill r13=[r3],16
 	nop.i 0
 	;;
