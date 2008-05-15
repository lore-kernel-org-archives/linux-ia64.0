From: "Huang, Xiaolan" <xiaolan.huang@intel.com>
Date: Thu, 15 May 2008 02:18:41 +0000
Subject: [PATCH 2.6.26-rc1] ia64arch: fix personality(PER_LINUX32) performance issue
Message-Id: <7B2CABB47D5B094AAACC8A1E001B82F502F3DBF3@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch aims to fix a performance issue for the syscall 
personality(PER_LINUX32).

On IA-64 box, the syscall personality (PER_LINUX32) has poor performance

because it failed to find the Linux/x86 execution domain. Then it tried 
to load the kernel module however it failed always and it used the
default 
execution domain PER_LINUX instead. Requesting kernel modules is very 
expensive. It caused the performance issue. (see the 
function lookup_exec_domain in kernel/exec_domain.c). 

To resolve the issue, execution domain Linux/x86 is always registered in

initialization time for IA-64 architecture.

Signed-off-by: Xiaolan Huang <xiaolan.huang@intel.com>

diff -uprN -X linux-2.6.26-rc1/Documentation/dontdiff
linux-2.6.26-rc1/arch/ia64/ia32/ia32_support.c
linux-2.6.26-fix/arch/ia64/ia32/ia32_support.c
--- linux-2.6.26-rc1/arch/ia64/ia32/ia32_support.c	2008-05-04
02:59:44.000000000 +0800
+++ linux-2.6.26-fix/arch/ia64/ia32/ia32_support.c	2008-05-15
00:48:46.000000000 +0800
@@ -15,7 +15,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/mm.h>
-#include <linux/personality.h>
 #include <linux/sched.h>
 
 #include <asm/intrinsics.h>
@@ -29,7 +28,6 @@
 
 extern int die_if_kernel (char *str, struct pt_regs *regs, long err);
 
-struct exec_domain ia32_exec_domain;
 struct page *ia32_shared_page[NR_CPUS];
 unsigned long *ia32_boot_gdt;
 unsigned long *cpu_gdt_table[NR_CPUS];
@@ -240,14 +238,6 @@ ia32_cpu_init (void)
 static int __init
 ia32_init (void)
 {
-	ia32_exec_domain.name = "Linux/x86";
-	ia32_exec_domain.handler = NULL;
-	ia32_exec_domain.pers_low = PER_LINUX32;
-	ia32_exec_domain.pers_high = PER_LINUX32;
-	ia32_exec_domain.signal_map = default_exec_domain.signal_map;
-	ia32_exec_domain.signal_invmap default_exec_domain.signal_invmap;
-	register_exec_domain(&ia32_exec_domain);
-
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
 	{
 		extern struct kmem_cache *ia64_partial_page_cachep;
diff -uprN -X linux-2.6.26-rc1/Documentation/dontdiff
linux-2.6.26-rc1/arch/ia64/mm/init.c
linux-2.6.26-fix/arch/ia64/mm/init.c
--- linux-2.6.26-rc1/arch/ia64/mm/init.c	2008-05-04
02:59:44.000000000 +0800
+++ linux-2.6.26-fix/arch/ia64/mm/init.c	2008-05-15
00:49:23.000000000 +0800
@@ -719,3 +719,28 @@ out:
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif
+
+/*
+ * Even when CONFIG_IA32_SUPPORT is not enabled it is
+ * useful to have the Linux/x86 domain registered to
+ * avoid an attempted module load when emulators call
+ * personality(PER_LINUX32). This saves several milliseconds
+ * on each such call.
+ */
+static struct exec_domain ia32_exec_domain;
+
+static int __init
+per_linux32_init(void)
+{
+	ia32_exec_domain.name = "Linux/x86";
+	ia32_exec_domain.handler = NULL;
+	ia32_exec_domain.pers_low = PER_LINUX32;
+	ia32_exec_domain.pers_high = PER_LINUX32;
+	ia32_exec_domain.signal_map = default_exec_domain.signal_map;
+	ia32_exec_domain.signal_invmap default_exec_domain.signal_invmap;
+	register_exec_domain(&ia32_exec_domain);
+
+	return 0;
+}
+
+__initcall(per_linux32_init);


Thanks
Xiaolan
