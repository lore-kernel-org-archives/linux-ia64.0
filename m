From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 03:10:53 +0000
Subject: [PATCH] [IA64] kexec/kdump: Pass in physical addresses to purgatory
Message-Id: <20061213031051.GI22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

*** Kernel portion of this patch, kexec-tools portion to follow ***

Currently the purgatory code for ia64 has the PAGE_OFFSET hardcoded,
and uses this to perform the equivalent of __pa() on some of the
data contained inside ia64_boot_param.

This is problematic if the kernel (or hypervisor or whatever)
is running with a PAGE_OFFSET different to that which kexec-tools
was compiled with. (purgatory is supplied by kexec-tools).

In order to address this problem, the code below makes
the __pa() translations in the kernel before going into pugatory.
Only the translations that are needed have been made to keep
things simple. But more could be added.

This does solve a real problem when running the xen port of ia64,
as xen has a different PAGE_OFFSET to Linux.

There is also a kexec-tools portion of this patch, which I will
post as a reply to this patch.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-12-13 10:03:43.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-12-13 10:17:03.000000000 +0900
@@ -14,13 +14,14 @@
 #include <linux/kexec.h>
 #include <linux/cpu.h>
 #include <linux/irq.h>
+#include <linux/efi.h>
 #include <asm/mmu_context.h>
 #include <asm/setup.h>
 #include <asm/delay.h>
 #include <asm/meminit.h>
 
 typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
-		struct ia64_boot_param *, unsigned long);
+		unsigned long, unsigned long);
 
 struct kimage *ia64_kimage;
 
@@ -77,6 +78,23 @@
 }
 
 /*
+ * boot_param is used inside purgatory and purgatory runs
+ * in physical mode, so translate the addresses that purgatory
+ * accesses from virtual to physical.
+ */
+static unsigned machine_kexec_prepare_boot_param (void)
+{
+	efi_system_table_t *systab;
+
+	systab = (efi_system_table_t *)__va(ia64_boot_param->efi_systab);
+	systab->runtime->set_virtual_address_map +				__pa(systab->runtime->set_virtual_address_map);
+	systab->runtime = (efi_runtime_services_t *)__pa(systab->runtime);
+
+	return __pa(ia64_boot_param);
+}
+
+/*
  * Do not allocate memory (or fail in any way) in machine_kexec().
  * We are past the point of no return, committed to rebooting now.
  */
@@ -121,7 +139,7 @@
 	}
 	platform_kernel_launch_event();
 	rnk = (relocate_new_kernel_t)&code_addr;
-	(*rnk)(image->head, image->start, ia64_boot_param,
+	(*rnk)(image->head, image->start, machine_kexec_prepare_boot_param(),
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));
 	BUG();
 }
Index: linux-2.6/arch/ia64/kernel/relocate_kernel.S
=================================--- linux-2.6.orig/arch/ia64/kernel/relocate_kernel.S	2006-12-13 10:03:40.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/relocate_kernel.S	2006-12-13 10:04:17.000000000 +0900
@@ -57,7 +57,7 @@
 1:
 	//physical mode code begin
 	mov b6=in1
-	dep r28=0,in2,61,3	//to physical address
+	mov r28=in2
 
 	// purge all TC entries
 #define O(member)       IA64_CPUINFO_##member##_OFFSET
