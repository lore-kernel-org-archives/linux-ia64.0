From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Nov 2005 21:56:46 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200511292156.jATLukqa005505@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/ia64_ksyms.c |    1 +
 arch/ia64/kernel/kprobes.c    |    2 +-
 arch/ia64/kernel/traps.c      |   18 ------------------
 include/asm-ia64/page.h       |    3 ++-
 4 files changed, 4 insertions(+), 20 deletions(-)

Dean Roe:
      [IA64] - Make pfn_valid more precise for SGI Altix systems

Keshavamurthy Anil S:
      [IA64] Remove getting break_num by decoding instruction

diff-tree 5a94bcfd2a18edcf368b3128c7df07b58e529932 (from b77dae5293efba42ea1ff04d410ee68e66d5b0cf)
Author: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date:   Tue Nov 22 14:15:49 2005 -0800

    [IA64] Remove getting break_num by decoding instruction
    
    break.b always sets cr.iim to 0 and the current code tries to
    get the break_num by decoding instruction. However, their
    seems to be a race condition while reading the regs->cr_iip,
    as on other cpu the break.b at regs->cr_iip might have been
    replaced with the original instruction as a result of
    unregister_kprobe() and hence decoding instruction to
    obtain break_num will result in wrong value in this case.
    
    Also includes changes to kprobes.c which now has to handle
    break number zero.
    
    Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 801eeae..2895d6e 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -740,7 +740,7 @@ int __kprobes kprobe_exceptions_notify(s
 	switch(val) {
 	case DIE_BREAK:
 		/* err is break number from ia64_bad_break() */
-		if (args->err = 0x80200 || args->err = 0x80300)
+		if (args->err = 0x80200 || args->err = 0x80300 || args->err = 0)
 			if (pre_kprobes_handler(args))
 				ret = NOTIFY_STOP;
 		break;
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index fba5fdd..d3e0ecb 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -132,24 +132,6 @@ __kprobes ia64_bad_break (unsigned long 
 	siginfo_t siginfo;
 	int sig, code;
 
-	/* break.b always sets cr.iim to 0, which causes problems for
-	 * debuggers.  Get the real break number from the original instruction,
-	 * but only for kernel code.  User space break.b is left alone, to
-	 * preserve the existing behaviour.  All break codings have the same
-	 * format, so there is no need to check the slot type.
-	 */
-	if (break_num = 0 && !user_mode(regs)) {
-		struct ia64_psr *ipsr = ia64_psr(regs);
-		unsigned long *bundle = (unsigned long *)regs->cr_iip;
-		unsigned long slot;
-		switch (ipsr->ri) {
-		      case 0:  slot = (bundle[0] >>  5); break;
-		      case 1:  slot = (bundle[0] >> 46) | (bundle[1] << 18); break;
-		      default: slot = (bundle[1] >> 23); break;
-		}
-		break_num = ((slot >> 36 & 1) << 20) | (slot >> 6 & 0xfffff);
-	}
-
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
 	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm = break_num;

diff-tree b77dae5293efba42ea1ff04d410ee68e66d5b0cf (from 624f54be206adf970cd8eece16446b027913e533)
Author: Dean Roe <roe@sgi.com>
Date:   Wed Nov 9 14:25:06 2005 -0600

    [IA64] - Make pfn_valid more precise for SGI Altix systems
    
    A single SGI Altix system can be divided into multiple partitions,
    each running their own instance of the Linux kernel.  pfn_valid()
    is currently not optimal for any but the first partition, since it
    does not compare the pfn with min_low_pfn before calling the more
    costly ia64_pfn_valid().
    
    Signed-off-by: Dean Roe <roe@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 0157281..5db9d3b 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -42,6 +42,7 @@ EXPORT_SYMBOL(clear_page);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/bootmem.h>
+EXPORT_SYMBOL(min_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 #endif
 
diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 9dd9da1..5e6362a 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -110,8 +110,9 @@ extern int ia64_pfn_valid (unsigned long
 # define pfn_to_page(pfn)	(mem_map + (pfn))
 #elif defined(CONFIG_DISCONTIGMEM)
 extern struct page *vmem_map;
+extern unsigned long min_low_pfn;
 extern unsigned long max_low_pfn;
-# define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
 #endif
