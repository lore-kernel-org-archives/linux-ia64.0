From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 05:53:58 +0000
Subject: [patch] use srlz.d instead of srlz.i in ia64_leave_kernel()
Message-Id: <16962.22006.926610.243102@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch switches the srlz.i in ia64_leave_kernel() to srlz.d.  As
per architecture manual, the former is needed only to ensure that the
clearing of PSR.IC is seen by the VHPT for subsequent instruction
fetches.  However, since the remainder of the code (up to and
including the RFI instruction) is mapped by a pinned TLB entry, there
is no chance of an iTLB miss and we don't care whether or not the VHPT
sees PSR.IC cleared.  Since srlz.d is substantially cheaper than
srlz.i, this should shave off a few cycles off the interrupt path
(unverified though; I'm not setup to measure this at the moment).

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/entry.S 1.88 vs edited ==--- 1.88/arch/ia64/kernel/entry.S	2005-03-23 14:30:21 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-23 21:47:38 -08:00
@@ -880,7 +880,7 @@
 	ldf.fill f7=[r2],PT(F11)-PT(F7)
 	ldf.fill f8=[r3],32
 	;;
-	srlz.i			// ensure interruption collection is off
+	srlz.d	// ensure that inter. collection is off (VHPT is don't care, since text is pinned)
 	mov ar.ccv=r15
 	;;
 	ldf.fill f11=[r2]
