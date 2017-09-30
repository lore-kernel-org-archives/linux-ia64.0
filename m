From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 30 Sep 2017 02:53:13 +0000
Subject: [PATCHv3 1/7] switch dereference_function_descriptor() to `unsigned long'
Message-Id: <20170930025319.987-2-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Convert dereference_function_descriptor() to accept and return
`unsigned long'. There will be two new ARCH function for kernel
and module function pointer dereference, which will work with
`unsigned long', so the patch unifies interfaces.

Besides, dereference_function_descriptor() mostly work with
`unsigned long':

drivers/misc/kgdbts.c:
addr = (unsigned long) dereference_function_descriptor((void *)addr);

init/main.c:
addr = (unsigned long) dereference_function_descriptor(fn);

kernel/extable.c:
addr = (unsigned long) dereference_function_descriptor(ptr);

kernel/module.c:
unsigned long a = (unsigned long)dereference_function_descriptor(addr);

Convert dereference_function_descriptor() users tree-wide.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Tested-by: Helge Deller <deller@gmx.de> # parisc64
Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
Tested-by: Tony Luck <tony.luck@intel.com> # ia64
---
 arch/ia64/include/asm/sections.h    | 6 +++---
 arch/parisc/include/asm/sections.h  | 2 +-
 arch/parisc/kernel/process.c        | 6 +++---
 arch/parisc/mm/init.c               | 4 ++--
 arch/powerpc/include/asm/sections.h | 6 +++---
 drivers/misc/kgdbts.c               | 2 +-
 init/main.c                         | 2 +-
 kernel/extable.c                    | 2 +-
 kernel/module.c                     | 2 +-
 lib/vsprintf.c                      | 2 +-
 10 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 2ab2003698ef..de6bfa1ef8fb 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -27,13 +27,13 @@ extern char __start_unwind[], __end_unwind[];
 extern char __start_ivt_text[], __end_ivt_text[];
 
 #undef dereference_function_descriptor
-static inline void *dereference_function_descriptor(void *ptr)
+static inline unsigned long dereference_function_descriptor(unsigned long ptr)
 {
-	struct fdesc *desc = ptr;
+	struct fdesc *desc = (struct fdesc *)ptr;
 	void *p;
 
 	if (!probe_kernel_address(&desc->ip, p))
-		ptr = p;
+		ptr = (unsigned long)p;
 	return ptr;
 }
 
diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
index 9d13c3507ad6..59fbe0067112 100644
--- a/arch/parisc/include/asm/sections.h
+++ b/arch/parisc/include/asm/sections.h
@@ -6,7 +6,7 @@
 
 #ifdef CONFIG_64BIT
 #undef dereference_function_descriptor
-void *dereference_function_descriptor(void *);
+unsigned long dereference_function_descriptor(unsigned long);
 #endif
 
 #endif
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index 30f92391a93e..d350aa913acc 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -267,13 +267,13 @@ get_wchan(struct task_struct *p)
 }
 
 #ifdef CONFIG_64BIT
-void *dereference_function_descriptor(void *ptr)
+unsigned long dereference_function_descriptor(unsigned long ptr)
 {
-	Elf64_Fdesc *desc = ptr;
+	Elf64_Fdesc *desc = (Elf64_Fdesc *)ptr;
 	void *p;
 
 	if (!probe_kernel_address(&desc->addr, p))
-		ptr = p;
+		ptr = (unsigned long)p;
 	return ptr;
 }
 #endif
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 1ca9a2b4239f..06e1b79e2946 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -389,10 +389,10 @@ static void __init setup_bootmem(void)
 static int __init parisc_text_address(unsigned long vaddr)
 {
 	static unsigned long head_ptr __initdata;
+	unsigned long addr = (unsigned long)&parisc_kernel_start;
 
 	if (!head_ptr)
-		head_ptr = PAGE_MASK & (unsigned long)
-			dereference_function_descriptor(&parisc_kernel_start);
+		head_ptr = PAGE_MASK & dereference_function_descriptor(addr);
 
 	return core_kernel_text(vaddr) || vaddr = head_ptr;
 }
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 7902d6358854..67379b8945e8 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -66,13 +66,13 @@ static inline int overlaps_kvm_tmp(unsigned long start, unsigned long end)
 
 #ifdef PPC64_ELF_ABI_v1
 #undef dereference_function_descriptor
-static inline void *dereference_function_descriptor(void *ptr)
+static inline unsigned long dereference_function_descriptor(unsigned long ptr)
 {
-	struct ppc64_opd_entry *desc = ptr;
+	struct ppc64_opd_entry *desc = (struct ppc64_opd_entry *)ptr;
 	void *p;
 
 	if (!probe_kernel_address(&desc->funcaddr, p))
-		ptr = p;
+		ptr = (unsigned long)p;
 	return ptr;
 }
 #endif /* PPC64_ELF_ABI_v1 */
diff --git a/drivers/misc/kgdbts.c b/drivers/misc/kgdbts.c
index fc7efedbc4be..6a5a159dfb75 100644
--- a/drivers/misc/kgdbts.c
+++ b/drivers/misc/kgdbts.c
@@ -225,7 +225,7 @@ static unsigned long lookup_addr(char *arg)
 		addr = (unsigned long)_do_fork;
 	else if (!strcmp(arg, "hw_break_val"))
 		addr = (unsigned long)&hw_break_val;
-	addr = (unsigned long) dereference_function_descriptor((void *)addr);
+	addr = dereference_function_descriptor(addr);
 	return addr;
 }
 
diff --git a/init/main.c b/init/main.c
index 83bdfa4750b1..ac56f7a4501f 100644
--- a/init/main.c
+++ b/init/main.c
@@ -764,7 +764,7 @@ static bool __init_or_module initcall_blacklisted(initcall_t fn)
 	if (list_empty(&blacklisted_initcalls))
 		return false;
 
-	addr = (unsigned long) dereference_function_descriptor(fn);
+	addr = dereference_function_descriptor((unsigned long)fn);
 	sprint_symbol_no_offset(fn_name, addr);
 
 	/*
diff --git a/kernel/extable.c b/kernel/extable.c
index 9aa1cc41ecf7..e48d6ba4ce6c 100644
--- a/kernel/extable.c
+++ b/kernel/extable.c
@@ -167,7 +167,7 @@ int kernel_text_address(unsigned long addr)
 int func_ptr_is_kernel_text(void *ptr)
 {
 	unsigned long addr;
-	addr = (unsigned long) dereference_function_descriptor(ptr);
+	addr = dereference_function_descriptor((unsigned long)ptr);
 	if (core_kernel_text(addr))
 		return 1;
 	return is_module_text_address(addr);
diff --git a/kernel/module.c b/kernel/module.c
index de66ec825992..ea77ab13bead 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1067,7 +1067,7 @@ EXPORT_SYMBOL(__symbol_put);
 void symbol_put_addr(void *addr)
 {
 	struct module *modaddr;
-	unsigned long a = (unsigned long)dereference_function_descriptor(addr);
+	unsigned long a = dereference_function_descriptor((unsigned long)addr);
 
 	if (core_kernel_text(a))
 		return;
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 86c3385b9eb3..bcd906a39010 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1723,7 +1723,7 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	switch (*fmt) {
 	case 'F':
 	case 'f':
-		ptr = dereference_function_descriptor(ptr);
+		ptr = (void *)dereference_function_descriptor((unsigned long)ptr);
 		/* Fallthrough */
 	case 'S':
 	case 's':
-- 
2.14.2

