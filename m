From: Helge Deller <deller@gmx.de>
Date: Tue, 19 Sep 2017 20:03:57 +0000
Subject: Re: [PATCH 0/5] [RFC] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170919200357.GA15803@p100.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170918174432.4fksyzco2g6gczwe@intel.com>
 <20170918183902.GA30752@p100.box>
 <20170919020537.GA16991@jagdpanzerIV.localdomain>
 <f1e7c2b0-8c52-7e21-b311-d886f5c4c20e@gmx.de>
In-Reply-To: <f1e7c2b0-8c52-7e21-b311-d886f5c4c20e@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "Luck, Tony" <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

* Helge Deller <deller@gmx.de>:
> On 19.09.2017 04:05, Sergey Senozhatsky wrote:
> >On (09/18/17 20:39), Helge Deller wrote:
> >>I did tried your testcases [on parisc] too.
> ...
> >>and here is "modprobe zram":
> >>  printk#7 __UNIQUE_ID_vermagic8+0xb9a4/0xbd04 [zram]
> >>  printk#8 __UNIQUE_ID_vermagic8+0xb9a4/0xbd04 [zram]
> >>  printk#9 do_one_initcall+0x194/0x290
> >>  printk#10 do_one_initcall+0x194/0x290
> >>  printk#11 do_one_initcall+0x194/0x290
> >>  printk#12 do_one_initcall+0x194/0x290
> >>  printk#13 zram_init+0x22c/0x2a0 [zram]
> >>  printk#14 zram_init+0x22c/0x2a0 [zram]
> >>  printk#15 zram_init+0x22c/0x2a0 [zram]
> >>  printk#16 zram_init+0x22c/0x2a0 [zram]
> >>
> >>I wonder why printk#7 and printk#8 don't show "zram_init"...
> >
> >interesting... what does the unpatched kernel show?
> 
> Really strange.
> The unpatched kernel shows __UNIQUE_ID_vermagic8+0xb9a4/0xbd04 too.
> The symbol should be known, because later on in printk13 it shows correctly zram_init.
> I'll need to dig deeper into it, but at least the regression is not due
> to your patch.

Sergey, I was wrong with this assumption.

Your implementation of dereference_module_function_descriptor() in
arch/parisc/kernel/module.c is faulty.
mod->arch.fdesc_offset is relative to the base address of the module,
so you need to add to mod->core_layout.base.

Here is the relevant patch to fix this issue (against mainline).
Additionally I compare against mod->arch.fdesc_count instead of
mod->arch.fdesc_max.
Can you please fold it into your patch
[PATCH 4/5] parisc64: Add .opd based function descriptor dereference
for the next round?

Thanks,
Helge

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index f1a7693..ae3e6c5 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -66,6 +66,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/unwind.h>
+#include <asm/sections.h>
 
 #if 0
 #define DEBUGP printk
@@ -954,3 +955,19 @@ void module_arch_cleanup(struct module *mod)
 {
 	deregister_unwind_table(mod);
 }
+
+#ifdef CONFIG_64BIT
+unsigned long dereference_module_function_descriptor(struct module *mod,
+					     unsigned long addr)
+{
+	unsigned long opd_start = (Elf64_Addr) mod->core_layout.base
+					+ mod->arch.fdesc_offset;
+	unsigned long opd_end = opd_start
+			+ mod->arch.fdesc_count * sizeof(Elf64_Fdesc);
+
+	if (addr < opd_start || addr >= opd_end)
+		return addr;
+
+	return (unsigned long) dereference_function_descriptor((void *) addr);
+}
+#endif
