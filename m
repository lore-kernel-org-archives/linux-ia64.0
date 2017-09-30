From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 30 Sep 2017 02:53:16 +0000
Subject: [PATCHv3 4/7] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20170930025319.987-5-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We are moving towards separate kernel and module function descriptor
dereference callbacks. This patch enables it for powerpc64.

For pointers that belong to the kernel
-  Added __start_opd and __end_opd pointers, to track the kernel
   .opd section address range;

-  Added dereference_kernel_function_descriptor(). Now we
   will dereference only function pointers that are within
   [__start_opd, __end_opd];

For pointers that belong to a module
-  Added dereference_module_function_descriptor() to handle module
   function descriptor dereference. Now we will dereference only
   pointers that are within [module->opd.start, module->opd.end].

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Tested-by: Helge Deller <deller@gmx.de> # parisc64
Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
Tested-by: Tony Luck <tony.luck@intel.com> # ia64
---
 arch/powerpc/include/asm/module.h   |  3 +++
 arch/powerpc/include/asm/sections.h | 11 +++++++++++
 arch/powerpc/kernel/module_64.c     | 16 ++++++++++++++++
 arch/powerpc/kernel/vmlinux.lds.S   |  2 ++
 4 files changed, 32 insertions(+)

diff --git a/arch/powerpc/include/asm/module.h b/arch/powerpc/include/asm/module.h
index 6c0132c7212f..7e28442827f1 100644
--- a/arch/powerpc/include/asm/module.h
+++ b/arch/powerpc/include/asm/module.h
@@ -45,6 +45,9 @@ struct mod_arch_specific {
 	unsigned long tramp;
 #endif
 
+	/* For module function descriptor dereference */
+	unsigned long start_opd;
+	unsigned long end_opd;
 #else /* powerpc64 */
 	/* Indices of PLT sections within module. */
 	unsigned int core_plt_section;
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 67379b8945e8..6b4ee0d1645f 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -75,6 +75,17 @@ static inline unsigned long dereference_function_descriptor(unsigned long ptr)
 		ptr = (unsigned long)p;
 	return ptr;
 }
+
+#undef dereference_kernel_function_descriptor
+static inline unsigned long
+dereference_kernel_function_descriptor(unsigned long addr)
+{
+	if (addr < (unsigned long)__start_opd ||
+			addr >= (unsigned long)__end_opd)
+		return addr;
+
+	return dereference_function_descriptor(addr);
+}
 #endif /* PPC64_ELF_ABI_v1 */
 
 #endif
diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
index 0b0f89685b67..94caec045a90 100644
--- a/arch/powerpc/kernel/module_64.c
+++ b/arch/powerpc/kernel/module_64.c
@@ -344,6 +344,11 @@ int module_frob_arch_sections(Elf64_Ehdr *hdr,
 		else if (strcmp(secstrings+sechdrs[i].sh_name,"__versions")=0)
 			dedotify_versions((void *)hdr + sechdrs[i].sh_offset,
 					  sechdrs[i].sh_size);
+		else if (!strcmp(secstrings + sechdrs[i].sh_name, ".opd")) {
+			me->arch.start_opd = sechdrs[i].sh_addr;
+			me->arch.end_opd = sechdrs[i].sh_addr +
+					   sechdrs[i].sh_size;
+		}
 
 		/* We don't handle .init for the moment: rename to _init */
 		while ((p = strstr(secstrings + sechdrs[i].sh_name, ".init")))
@@ -712,6 +717,17 @@ int apply_relocate_add(Elf64_Shdr *sechdrs,
 	return 0;
 }
 
+#ifdef PPC64_ELF_ABI_v1
+unsigned long dereference_module_function_descriptor(struct module *mod,
+						     unsigned long addr)
+{
+	if (addr < mod->arch.start_opd || addr >= mod->arch.end_opd)
+		return addr;
+
+	return dereference_function_descriptor(addr);
+}
+#endif /* PPC64_ELF_ABI_v1 */
+
 #ifdef CONFIG_DYNAMIC_FTRACE
 
 #ifdef CC_USING_MPROFILE_KERNEL
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index 882628fa6987..70e10251e083 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -277,7 +277,9 @@ SECTIONS
 	}
 
 	.opd : AT(ADDR(.opd) - LOAD_OFFSET) {
+		__start_opd = .;
 		*(.opd)
+		__end_opd = .;
 	}
 
 	. = ALIGN(256);
-- 
2.14.2

