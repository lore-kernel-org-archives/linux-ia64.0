From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 03:29:37 +0000
Subject: Re: [PATCH] kexec-tools: ia64: Pass in physical addresses to purgatory
Message-Id: <20061213032936.GA977@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061213031212.GJ22902@verge.net.au>
In-Reply-To: <20061213031212.GJ22902@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry, the previous version of this patch was against my development tree.
Here is a version that should apply to the current kexec-tools-testing
tree.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

*** kexec-tools portion of this patch, kernel portion posted separately *** 

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

There is also a kernel portion of this patch, which I will
post separately.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: kexec-tools-unstable/purgatory/arch/ia64/purgatory-ia64.c
=================================--- kexec-tools-unstable.orig/purgatory/arch/ia64/purgatory-ia64.c	2006-12-13 12:24:02.000000000 +0900
+++ kexec-tools-unstable/purgatory/arch/ia64/purgatory-ia64.c	2006-12-13 12:26:40.000000000 +0900
@@ -21,8 +21,6 @@
 #include <string.h>
 #include "purgatory-ia64.h"
 
-#define PAGE_OFFSET             0xe000000000000000UL
-
 #define EFI_PAGE_SHIFT          12
 #define EFI_PAGE_SIZE		(1UL<<EFI_PAGE_SHIFT)
 #define EFI_PAGE_ALIGN(x)	((x + EFI_PAGE_SIZE - 1)&~(EFI_PAGE_SIZE-1))
@@ -146,11 +144,6 @@
 	reset_vga();
 }
 
-inline unsigned long PA(unsigned long addr)
-{
-	return addr - PAGE_OFFSET;
-}
-
 void
 patch_efi_memmap(struct kexec_boot_params *params,
 		struct ia64_boot_param *boot_param)
@@ -267,9 +260,9 @@
 	memcpy(command_line + command_line_len,
 		__dummy_efi_function, len);
 	systab = (efi_system_table_t *)new_boot_param->efi_systab;
-	runtime = (efi_runtime_services_t *)PA(systab->runtime);
+	runtime = (efi_runtime_services_t *)systab->runtime;
 	set_virtual_address_map -		(unsigned long *)PA(runtime->set_virtual_address_map);
+		(unsigned long *)runtime->set_virtual_address_map;
 	*(set_virtual_address_map)  		(unsigned long)(command_line + command_line_len);
 	flush_icache_range(command_line + command_line_len, len);
