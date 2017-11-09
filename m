From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 09 Nov 2017 23:48:25 +0000
Subject: [PATCHv4 1/6] sections: split dereference_function_descriptor()
Message-Id: <20171109234830.5067-2-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

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
 include/asm-generic/sections.h | 8 ++++++--
 include/linux/module.h         | 3 +++
 kernel/module.c                | 6 ++++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 03cc5f9bba71..849cd8eb5ca0 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -30,6 +30,7 @@
  *	__ctors_start, __ctors_end
  *	__irqentry_text_start, __irqentry_text_end
  *	__softirqentry_text_start, __softirqentry_text_end
+ *	__start_opd, __end_opd
  */
 extern char _text[], _stext[], _etext[];
 extern char _data[], _sdata[], _edata[];
@@ -49,12 +50,15 @@ extern char __start_once[], __end_once[];
 /* Start and end of .ctors section - used for constructor calls. */
 extern char __ctors_start[], __ctors_end[];
 
+/* Start and end of .opd section - used for function descriptors. */
+extern char __start_opd[], __end_opd[];
+
 extern __visible const void __nosave_begin, __nosave_end;
 
-/* function descriptor handling (if any).  Override
- * in asm/sections.h */
+/* Function descriptor handling (if any).  Override in asm/sections.h */
 #ifndef dereference_function_descriptor
 #define dereference_function_descriptor(p) (p)
+#define dereference_kernel_function_descriptor(p) (p)
 #endif
 
 /* random extra sections (if any).  Override
diff --git a/include/linux/module.h b/include/linux/module.h
index c69b49abe877..9dac6973b001 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -606,6 +606,9 @@ int ref_module(struct module *a, struct module *b);
 	__mod ? __mod->name : "kernel";		\
 })
 
+/* Dereference module function descriptor */
+void *dereference_module_function_descriptor(struct module *mod, void *ptr);
+
 /* For kallsyms to ask for address resolution.  namebuf should be at
  * least KSYM_NAME_LEN long: a pointer to namebuf is returned if
  * found, otherwise NULL. */
diff --git a/kernel/module.c b/kernel/module.c
index ab2978e4239c..1d6e996caa13 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -3938,6 +3938,12 @@ static const char *get_ksymbol(struct module *mod,
 	return symname(kallsyms, best);
 }
 
+void * __weak dereference_module_function_descriptor(struct module *mod,
+						     void *ptr)
+{
+	return ptr;
+}
+
 /* For kallsyms to ask for address resolution.  NULL means not found.  Careful
  * not to lock to avoid deadlock on oopses, simply disable preemption. */
 const char *module_address_lookup(unsigned long addr,
-- 
2.15.0

