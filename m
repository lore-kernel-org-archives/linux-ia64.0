From: Bob Montgomery <bob.montgomery@hp.com>
Date: Thu, 31 Mar 2005 20:17:34 +0000
Subject: [PATCH]  Can't unwind through dispatch_illegal_op_fault
Message-Id: <1112300254.498.198.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Here is the patch worked out with David Mosberger to fix the unwind info
for dispatch_illegal_op_fault in ivt.S.  Before adding this patch, an
illegal op in the kernel would not show a complete stack trace in the
oops message.

Add PT_REGS_UNWIND_INFO to dispatch_illegal_op_fault to allow stack
unwind to continue through that stack level when kernel code commits an
illegal operation. 

Signed-off-by: Bob Montgomery <bob.montgomery@hp.com> 

--- linux-2.6.11.2/arch/ia64/kernel/ivt.S	2005-03-30 14:52:53.291418136 -0700
+++ linux-2.6.11.2-bobm/arch/ia64/kernel/ivt.S	2005-03-30 14:03:29.687938816 -0700
@@ -957,6 +957,8 @@ END(ia64_syscall_setup)
 	 * element, followed by the arguments.
 	 */
 ENTRY(dispatch_illegal_op_fault)
+	.prologue
+	.body
 	SAVE_MIN_WITH_COVER
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
@@ -969,6 +971,7 @@ ENTRY(dispatch_illegal_op_fault)
 	mov out0=ar.ec
 	;;
 	SAVE_REST
+	PT_REGS_UNWIND_INFO(0)
 	;;
 	br.call.sptk.many rp=ia64_illegal_op_fault
 .ret0:	;;




-- 
Bob Montgomery <bob.montgomery@hp.com>

