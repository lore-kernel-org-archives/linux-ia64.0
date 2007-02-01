From: Jay Lan <jlan@sgi.com>
Date: Thu, 01 Feb 2007 01:54:22 +0000
Subject: [PATCH] IA64 kexec-tools: efi_memmap overflow on large systems
Message-Id: <45C1484E.3020300@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080100040206020806040906"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080100040206020806040906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch fixes a efi_memmap overflow problem on large system.
Currently the kexec allocates statically 16k buffer to contain
efi_memmap. It can hold about 333 entries. It causes data
corruption on large system.

This patch would let kexec allocate the efi_memmap at run time using
the actual size allocated in the production kernel.


Signed-off-by: Jay Lan <jlan@sgi.com>

--------------080100040206020806040906
Content-Type: text/plain;
 name="efi-memmap-overflow"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="efi-memmap-overflow"

Index: kexec-tools-testing-20061214/kexec/arch/ia64/kexec-elf-ia64.c
===================================================================
--- kexec-tools-testing-20061214.orig/kexec/arch/ia64/kexec-elf-ia64.c	2006-12-14 01:12:03.000000000 -0600
+++ kexec-tools-testing-20061214/kexec/arch/ia64/kexec-elf-ia64.c	2007-01-31 19:33:23.000000000 -0600
@@ -47,6 +47,7 @@
 #include <arch/options.h>
 
 static const int probe_debug = 0;
+extern unsigned long saved_efi_memmap_size;
 
 /*
  * elf_ia64_probe - sanity check the elf image
@@ -229,8 +230,8 @@ int elf_ia64_load(int argc, char **argv,
         elf_rel_set_symbol(&info->rhdr, "__boot_param_base",
                         &boot_param_base, sizeof(long));
 
-	// reserve 8k for efi_memmap
-	efi_memmap_size = 1UL<<14;
+	// reserve efi_memmap of actual size allocated in production kernel
+	efi_memmap_size = saved_efi_memmap_size;
 	efi_memmap_buf = xmalloc(efi_memmap_size);
 	efi_memmap_base = add_buffer(info, efi_memmap_buf,
 			efi_memmap_size, efi_memmap_size, 4096, 0,
Index: kexec-tools-testing-20061214/kexec/arch/ia64/kexec-ia64.c
===================================================================
--- kexec-tools-testing-20061214.orig/kexec/arch/ia64/kexec-ia64.c	2006-12-14 01:12:03.000000000 -0600
+++ kexec-tools-testing-20061214/kexec/arch/ia64/kexec-ia64.c	2007-01-31 19:35:20.000000000 -0600
@@ -38,6 +38,7 @@
 
 static struct memory_range memory_range[MAX_MEMORY_RANGES];
 static int memory_ranges;
+unsigned long saved_efi_memmap_size;
 
 /* Reserve range for EFI memmap and Boot parameter */
 static int split_range(int range, unsigned long start, unsigned long end)
@@ -124,6 +125,7 @@ int get_memory_ranges(struct memory_rang
 			continue;
 		} else if (memcmp(str, "EFI Memory Map\n", 14) == 0) {
 			memory_ranges = split_range(memory_ranges, start, end);
+			saved_efi_memmap_size = end - start;
 			continue;
 		} else
 			continue;

--------------080100040206020806040906--
