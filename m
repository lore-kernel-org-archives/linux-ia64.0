From: Jack Steiner <steiner@sgi.com>
Date: Wed, 15 Feb 2006 21:29:22 +0000
Subject: [PATCH] - Missing check for TIF_WORK if trace/audit enabled
Message-Id: <20060215212922.GA28239@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


It appears that if trace/audit is enabled, the kernel fails to
check for pending work before returning to user mode. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>


---

Tony / Ken - check this carefully. This is not easy code to understand :-)

I noticed the problem running a signal test that sent SIGUSR2 signals to 
itself. Signals were being dropped. I isolated the problem to an uninitialzed
p6:
	
	ia64_trace_syscall -> work_pending_syscall_end -> work_processed_syscall

work_processed_syscall assumes p6 indicates if the kernel is returning to user mode.
Nothing set p6 for this particular path.



Index: linux/arch/ia64/kernel/entry.S
=================================--- linux.orig/arch/ia64/kernel/entry.S	2006-02-15 12:32:49.836316366 -0600
+++ linux/arch/ia64/kernel/entry.S	2006-02-15 15:09:49.983620290 -0600
@@ -569,6 +569,7 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 .mem.offset 0,0; st8.spill [r2]=r8		// store return value in slot for r8
 .mem.offset 8,0; st8.spill [r3]=r10		// clear error indication in slot for r10
 	br.call.sptk.many rp=syscall_trace_leave // give parent a chance to catch return value
+(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
 .ret3:	br.cond.sptk .work_pending_syscall_end
 
 strace_error:
