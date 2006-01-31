From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 10:16:48 +0000
Subject: [patch 0/6] remove non-functional code in ia64_leave_syscall
Message-Id: <200601311016.k0VAGvg19028@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In syscall leave path, cr.ifs gets the value direct from the
cover instruction.  We never want to restore cr.ifs from the
pt_regs.  The setting of p9 in ia64_leave_syscall is spurious
and unnecessary. (in the later part, it is reset to 0). This
patch cleans up the code.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/entry.S.orig	2006-01-31 02:44:56.406164880 -0800
+++ ./arch/ia64/kernel/entry.S	2006-01-31 03:08:49.949116069 -0800
@@ -739,7 +739,6 @@ ENTRY(ia64_leave_syscall)
 	;;
 	invala			// M0|1 invalidate ALAT
 	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
-	cmp.eq p9,p0=r0,r0	// A    set p9 to indicate that we should restore cr.ifs
 
 	ld8 r29=[r2],16		// M0|1 load cr.ipsr
 	ld8 r28=[r3],16		// M0|1 load cr.iip

