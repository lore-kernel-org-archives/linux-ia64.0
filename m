From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Tue, 19 Feb 2008 02:03:50 +0000
Subject: Re: [PATCH 4/5] signal(ia64): add a signal stack overflow check
Message-Id: <47BA3906.5080406@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47B95D4F.8030003@cn.fujitsu.com> <20080218123052.GG21012@parisc-linux.org>
In-Reply-To: <20080218123052.GG21012@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org



Matthew Wilcox wrote::
> On Mon, Feb 18, 2008 at 06:26:23PM +0800, Shi Weihua wrote:
>> +			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
>> +				new_rbs = (current->sas_ss_sp +
>> +					  sizeof(long) - 1) & ~(sizeof(long) - 1);
> 
> I know you're only moving this code, but how about fixing it to use
> ALIGN at the same time?
> 
> +			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
> +				new_rbs = ALIGN(current->sas_ss_sp,
> +						sizeof(long));
> 

Of course,we can improve the code by ALIGN.

---
The similar check has been added to x86_32(i386) in commit
id 83bd01024b1fdfc41d9b758e5669e80fca72df66.

So we add this check to ia64 and improve it a liitle bit in that
we need to check for stack overflow only when the signal is on stack.

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 

---
--- linux-2.6.25-rc2.orig/arch/ia64/kernel/signal.c	2008-02-16 04:57:20.000000000 +0800
+++ linux-2.6.25-rc2/arch/ia64/kernel/signal.c	2008-02-19 09:57:05.000000000 +0800
@@ -342,15 +342,33 @@ setup_frame (int sig, struct k_sigaction
 
 	new_sp = scr->pt.r12;
 	tramp_addr = (unsigned long) __kernel_sigtramp;
-	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags(new_sp) = 0) {
-		new_sp = current->sas_ss_sp + current->sas_ss_size;
-		/*
-		 * We need to check for the register stack being on the signal stack
-		 * separately, because it's switched separately (memory stack is switched
-		 * in the kernel, register stack is switched in the signal trampoline).
-		 */
-		if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
-			new_rbs = (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - 1);
+	if (ka->sa.sa_flags & SA_ONSTACK) {
+		int onstack = sas_ss_flags(new_sp);
+
+		if (onstack = 0) {
+			new_sp = current->sas_ss_sp + current->sas_ss_size;
+			/*
+			 * We need to check for the register stack being on the
+			 * signal stack separately, because it's switched
+			 * separately (memory stack is switched in the kernel,
+			 * register stack is switched in the signal trampoline).
+			 */
+			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
+				new_rbs = ALIGN(current->sas_ss_sp,
+						sizeof(long));
+		} else if (onstack = SS_ONSTACK) {
+			unsigned long check_sp;
+
+			/*
+			 * If we are on the alternate signal stack and would
+			 * overflow it, don't. Return an always-bogus address
+			 * instead so we will die with SIGSEGV.
+			 */
+			check_sp = (new_sp - sizeof(*frame)) & -STACK_ALIGN;
+			if (!likely(on_sig_stack(check_sp)))
+				return force_sigsegv_info(sig, (void __user *)
+							  check_sp);
+		}
 	}
 	frame = (void __user *) ((new_sp - sizeof(*frame)) & -STACK_ALIGN);
 

