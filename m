From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 27 Feb 2006 19:26:45 +0000
Subject: RE: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <200602271926.k1RJQjg02847@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Ken wrote on Thursday, February 23, 2006 6:34 PM
> It's not efficient to use a per-cpu variable just to store
> how many physical stack register a cpu has.  Ever since the
> incarnation of ia64 up till upcoming Montecito processor, that
> variable has "glued" to 96. Having a variable in memory means
> that the kernel is burning an extra cacheline access on every
> syscall and kernel exit path.  Such "static" value is better
> served with the instruction patching utility exists today.
> Convert ia64_phys_stacked_size_p8 into dynamic insn patching.
> 
> This also has a pleasant side effect of eliminating access to
> per-cpu area while psr.ic=0 in the kernel exit path. (fixable
> for per-cpu DTC work, but why bother?)
> 
> There are some concerns with the default value that the instruc-
> tion encoded in the kernel image.  It shouldn't be concerned.
> The reasons are:
> 
> (1) cpu_init() is called at CPU initialization.  In there, we
>     find out physical stack register size from PAL and patch
>     two instructions in kernel exit code.  The code in question
>     can not be executed before the patching is done.
> 
> (2) current implementation stores zero in ia64_phys_stacked_size_p8,
>     and that's what the current kernel exit path loads the value with.
>     With the new code, it is equivalent that we store reg size 96
>     in ia64_phys_stacked_size_p8, thus creating a better safety net.
>     Given (1) above can never fail, having (2) is just a bonus.
> 
> 
> All in all, this patch allow one less memory reference in the kernel
> exit path, thus reducing syscall and interrupt return latency; and
> avoid polluting potential useful data in the CPU cache.


I accidentally posted a variant of patch with IA64_NUM_PHYS_STACK_REG
set to 0 for the purpose of testing out correctness of instruction
patching.  Change that value to 96 as advertised.

- Ken



--- linux-2.6.15/include/asm-ia64/processor.h.orig	2006-02-27 12:19:47.793181185 -0800
+++ linux-2.6.15/include/asm-ia64/processor.h	2006-02-27 12:19:56.312712330 -0800
@@ -20,7 +20,7 @@
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
 
-#define IA64_NUM_PHYS_STACK_REG	0
+#define IA64_NUM_PHYS_STACK_REG	96
 #define IA64_NUM_DBG_REGS	8
 /*
  * Limits for PMC and PMD are set to less than maximum architected values


