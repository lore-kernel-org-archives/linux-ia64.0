From: Helge Deller <deller@gmx.de>
Date: Mon, 18 Sep 2017 18:39:02 +0000
Subject: Re: [PATCH 0/5] [RFC] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170918183902.GA30752@p100.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170918174432.4fksyzco2g6gczwe@intel.com>
In-Reply-To: <20170918174432.4fksyzco2g6gczwe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

* Luck, Tony <tony.luck@intel.com>:
> On Sat, Sep 16, 2017 at 12:53:42PM +0900, Sergey Senozhatsky wrote:
> > 	Hello
> > 
> > 	RFC
> > 
> > 	On some arches C function pointers are indirect and point to
> > a function descriptor, which contains the actual pointer to the code.
> > This mostly doesn't matter, except for cases when people want to print
> > out function pointers in symbolic format, because the usual '%pS/%ps'
> > does not work on those arches as expected. That's the reason why we
> > have '%pF/%pf', but since it's here because of a subtle ABI detail
> > specific to some arches (ppc64/ia64/parisc64) it's easy to misuse
> > '%pF/%pf' and '%pS/%ps' (see [1], for example).
> 
> A few new warnings when building on ia64:
> 
> arch/ia64/kernel/module.c:931: warning: passing argument 1 of 'dereference_function_descriptor' makes pointer from integer without a cast
> arch/ia64/kernel/module.c:931: warning: return makes integer from pointer without a cast
> kernel/kallsyms.c:325: warning: assignment makes integer from pointer without a cast
> kernel/kallsyms.c:325: warning: passing argument 1 of 'dereference_kernel_function_descriptor' makes pointer from integer without a cast


I got similiar warnings on parisc.
This patch on top of yours fixed those:

diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index bc2eae8..4f34b46 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -66,6 +66,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/unwind.h>
+#include <asm/sections.h>
 
 #if 0
 #define DEBUGP printk
@@ -959,12 +960,12 @@ void module_arch_cleanup(struct module *mod)
 unsigned long dereference_module_function_descriptor(struct module *mod,
 					     unsigned long addr)
 {
-	void *opd_sz = mod->arch.fdesc_offset +
+	unsigned long opd_sz = mod->arch.fdesc_offset +
 		       mod->arch.fdesc_max * sizeof(Elf64_Fdesc);
 
 	if (addr < mod->arch.fdesc_offset || opd_sz < addr)
 		return addr;
 
-	return dereference_function_descriptor(addr);
+	return (unsigned long) dereference_function_descriptor((void *) addr);
 }
 #endif
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index e2fc09e..76f4de6 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -322,7 +322,7 @@ const char *kallsyms_lookup(unsigned long addr,
 	if (is_ksym_addr(addr)) {
 		unsigned long pos;
 
-		addr = dereference_kernel_function_descriptor(addr);
+		addr = dereference_kernel_function_descriptor((void *) addr);
 		pos = get_symbol_pos(addr, symbolsize, offset);
 		/* Grab name */
 		kallsyms_expand_symbol(get_symbol_offset(pos),


I did tried your testcases too.

"echo 1 > /proc/sys/vm/drop_caches" gave correct output:
 printk#1 schedule_timeout+0x0/0x4a8
 printk#2 schedule_timeout+0x0/0x4a8
 printk#3 proc_sys_call_handler+0x120/0x180
 printk#4 proc_sys_call_handler+0x120/0x180
 printk#5 proc_sys_call_handler+0x120/0x180
 printk#6 proc_sys_call_handler+0x120/0x180

and here is "modprobe zram":
 printk#7 __UNIQUE_ID_vermagic8+0xb9a4/0xbd04 [zram]
 printk#8 __UNIQUE_ID_vermagic8+0xb9a4/0xbd04 [zram]
 printk#9 do_one_initcall+0x194/0x290
 printk#10 do_one_initcall+0x194/0x290
 printk#11 do_one_initcall+0x194/0x290
 printk#12 do_one_initcall+0x194/0x290
 printk#13 zram_init+0x22c/0x2a0 [zram]
 printk#14 zram_init+0x22c/0x2a0 [zram]
 printk#15 zram_init+0x22c/0x2a0 [zram]
 printk#16 zram_init+0x22c/0x2a0 [zram]

I wonder why printk#7 and printk#8 don't show "zram_init"...


Regarding your patches:

In arch/parisc/kernel/process.c:
+void *dereference_kernel_function_descriptor(void *ptr)
+{
+       if (ptr < (void *)__start_opd || (void *)__end_opd < ptr)

This needs to be (__end_opd is outside):
+       if (ptr < (void *)__start_opd || (void *)__end_opd <= ptr)

The same is true for the checks in the other arches.


I'd suggest to move the various
	extern char __start_opd[], __end_opd[];
out of arch/<arch>/include/asm/sections.h and into <asm-generic/sections.h>


I'll continue to test.

Helge
