From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 20:06:42 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 17 April 2003 1:52 pm, Jesse Barnes wrote:
> It would be helpful to apply the patch that Martin Hicks sent out
> awhile ago which will print the isr as well as the IP.  You can then
> decode the isr to figure out exactly what's causing the fault in your
> app.

I couldn't find this in the archives, but I got it out of David's
2.5 tree, and applied it for 2.4 as well.  Here it is if you
want to try it:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.889.308.20 -> 1.889.308.21
#	arch/ia64/kernel/traps.c	1.26    -> 1.26.1.1
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/03/18	mort@wildopensource.com	1.889.308.21
# [PATCH] ia64: print ISR for FPSWA faults
# 
# Here is a simple patch to also print isr during the handling of a
# floating point assist fault.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c	Thu Apr 17 13:41:11 2003
+++ b/arch/ia64/kernel/traps.c	Thu Apr 17 13:41:11 2003
@@ -336,8 +336,8 @@
 		fpu_swa_count = 0;
 	if ((++fpu_swa_count < 5) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
 		last_time = jiffies;
-		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx\n",
-		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri);
+		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx, isr %016lx\n",
+		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri, isr);
 	}
 
 	exception = fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr, &isr, &regs->pr,


