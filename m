From: Horms <horms@verge.net.au>
Date: Fri, 06 Oct 2006 04:11:16 +0000
Subject: [patch] kexec-tool: ia64: Obtain PAGE_OFFSET from running kernel
Message-Id: <20061006042056.263592000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently the page offset is hard coded to 0xe000000000000000UL
at compile time of kexec-tools. This patch changes things around
so the page offset is handed to purgatory by the kexecing kernel.

Note that this changes the ABI between purgatory (part of kexec-tools)
and the kernel kexec code. There is an accomanying kernel patch.

Signed-Off-By: Simon Horman <horms@verge.net.au>

index 2cc8302..395d97c 100644
Index: kexec-tools-unstable/purgatory/arch/ia64/entry.S
=================================--- kexec-tools-unstable.orig/purgatory/arch/ia64/entry.S	2006-09-27 17:42:53.000000000 +0900
+++ kexec-tools-unstable/purgatory/arch/ia64/entry.S	2006-09-28 15:41:19.000000000 +0900
@@ -35,14 +35,17 @@
 .align  32
 .proc   purgatory_start
 purgatory_start:
+	alloc r2 = ar.pfs, 1, 1, 3, 0
+	;;
+	mov loc0=in0
 	movl r2=__gp_value;;
 	ld8 gp=[r2];;
 	br.call.sptk.many b0=purgatory
 	;;
-	alloc r2 = ar.pfs, 0, 0, 2, 0
-	;;
 	mov out0=r28
-	movl out1=__vmcode_base;
+	movl out1=__vmcode_base
+	mov out2=loc0
+	;;
 	br.call.sptk.many b0=ia64_env_setup
 	movl r10=__kernel_entry;;
 	ld8 r14=[r10];;
Index: kexec-tools-unstable/purgatory/arch/ia64/purgatory-ia64.c
=================================--- kexec-tools-unstable.orig/purgatory/arch/ia64/purgatory-ia64.c	2006-09-27 17:42:53.000000000 +0900
+++ kexec-tools-unstable/purgatory/arch/ia64/purgatory-ia64.c	2006-09-28 15:41:44.000000000 +0900
@@ -21,8 +21,6 @@
 #include <string.h>
 #include "purgatory-ia64.h"
 
-#define PAGE_OFFSET             0xe000000000000000UL
-
 #define EFI_PAGE_SHIFT          12
 #define EFI_PAGE_SIZE		(1UL<<EFI_PAGE_SHIFT)
 #define EFI_PAGE_ALIGN(x)	((x + EFI_PAGE_SIZE - 1)&~(EFI_PAGE_SIZE-1))
@@ -146,9 +144,9 @@
 	reset_vga();
 }
 
-inline unsigned long PA(unsigned long addr)
+inline unsigned long PA(unsigned long addr, unsigned long page_offset)
 {
-	return addr - PAGE_OFFSET;
+	return addr - page_offset;
 }
 
 void
@@ -234,7 +232,7 @@
 
 void
 ia64_env_setup(struct ia64_boot_param *boot_param,
-	struct kexec_boot_params *params)
+	struct kexec_boot_params *params, unsigned long page_offset)
 {
 	unsigned long len;
         efi_system_table_t *systab;
@@ -265,9 +263,10 @@
 	memcpy(command_line + command_line_len,
 		__dummy_efi_function, len);
 	systab = (efi_system_table_t *)new_boot_param->efi_systab;
-	runtime = (efi_runtime_services_t *)PA(systab->runtime);
+	runtime = (efi_runtime_services_t *)PA(systab->runtime, page_offset);
 	set_virtual_address_map -		(unsigned long *)PA(runtime->set_virtual_address_map);
+		(unsigned long *)PA(runtime->set_virtual_address_map,
+				    page_offset);
 	*(set_virtual_address_map)  		(unsigned long)(command_line + command_line_len);
 	flush_icache_range(command_line + command_line_len, len);

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

