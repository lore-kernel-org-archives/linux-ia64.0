From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 16 Sep 2017 03:53:43 +0000
Subject: [PATCH 1/5] sections: split dereference_function_descriptor()
Message-Id: <20170916035347.19705-2-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

There are two format specifiers to print out a pointer in symbolic
format: '%pS/%ps' and '%pF/%pf'. On most architectures, the two
mean exactly the same thing, but some architectures (ia64, ppc64,
parisc64) use an indirect pointer for C function pointers, where
the function pointer points to a function descriptor (which in
turn contains the actual pointer to the code). The '%pF/%pf, when
used appropriately, automatically does the appropriate function
descriptor dereference on such architectures.

The "when used appropriately" part is tricky. Basically this is
a subtle ABI detail, specific to some platforms, that made it to
the API level and people can be unaware of it and miss the whole
"we need to dereference the function" business out. [1] proves
that point (note that it fixes only '%pF' and '%pS', there might
be '%pf' and '%ps' cases as well).

It appears that we can handle everything within the affected
arches and make '%pS/%ps' smart enough to retire '%pF/%pf'.
Function descriptors live in .opd elf section and all affected
arches (ia64, ppc64, parisc64) handle it properly for kernel
and modules. So we, technically, can decide if the dereference
is needed by simply looking at the pointer: if it belongs to
.opd section then we need to dereference it.

The kernel and modules have their own .opd sections, obviously,
that's why we need to split dereference_function_descriptor()
and use separate kernel and module dereference arch callbacks.

This patch does the first step, it
a) adds dereference_kernel_function_descriptor() function.
b) adds a weak alias to dereference_module_function_descriptor()
   function.

So, for the time being, we will have:
1) dereference_function_descriptor()
   A generic function, that simply dereferences the pointer. There is
   bunch of places that call it: kgdbts, init/main.c, extable, etc.

2) dereference_kernel_function_descriptor()
   A function to call on kernel symbols that does kernel .opd section
   address range test.

3) dereference_module_function_descriptor()
   A function to call on modules' symbols that does modules' .opd
   section address range test.

[1] https://marc.info/?l=linux-kernel&m0472969730573

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/asm-generic/sections.h | 4 ++--
 include/linux/moduleloader.h   | 4 ++++
 kernel/module.c                | 6 ++++++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index e5da44eddd2f..21d2165e531a 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -49,10 +49,10 @@ extern char __ctors_start[], __ctors_end[];
 
 extern __visible const void __nosave_begin, __nosave_end;
 
-/* function descriptor handling (if any).  Override
- * in asm/sections.h */
+/* Function descriptor handling (if any).  Override in asm/sections.h */
 #ifndef dereference_function_descriptor
 #define dereference_function_descriptor(p) (p)
+#define dereference_kernel_function_descriptor(p) (p)
 #endif
 
 /* random extra sections (if any).  Override
diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
index 4d0cb9bba93e..172904e9cded 100644
--- a/include/linux/moduleloader.h
+++ b/include/linux/moduleloader.h
@@ -85,6 +85,10 @@ void module_arch_cleanup(struct module *mod);
 /* Any cleanup before freeing mod->module_init */
 void module_arch_freeing_init(struct module *mod);
 
+/* Dereference module function descriptor */
+unsigned long dereference_module_function_descriptor(struct module *mod,
+						     unsigned long addr);
+
 #ifdef CONFIG_KASAN
 #include <linux/kasan.h>
 #define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
diff --git a/kernel/module.c b/kernel/module.c
index de66ec825992..87cdb46863cd 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2121,6 +2121,12 @@ void __weak module_arch_freeing_init(struct module *mod)
 {
 }
 
+unsigned long __weak dereference_module_function_descriptor(struct module *mod,
+							    unsigned long addr)
+{
+	return addr;
+}
+
 /* Free a module, remove from lists, etc. */
 static void free_module(struct module *mod)
 {
-- 
2.14.1

