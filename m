From: akpm@linux-foundation.org
Date: Tue, 06 Mar 2007 10:34:26 +0000
Subject: [patch 6/6] ia64 kexec: Use EFI_LOADER_DATA for ELF core header
Message-Id: <200703061034.l26AYQ4V019355@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Magnus Damm <magnus@valinux.co.jp>

The address where the ELF core header is stored is passed to the secondary
kernel as a kernel command line option.  The memory area for this header is
also marked as a separate EFI memory descriptor on ia64.

The separate EFI memory descriptor is at the moment of the type
EFI_UNUSABLE_MEMORY.  With such a type the secondary kernel skips over the
entire memory granule (config option, 16M or 64M) when detecting memory. 
If we are lucky we will just lose some memory, but if we happen to have
data in the same granule (such as an initramfs image), then this data will
never get mapped and the kernel bombs out when trying to access it.

So this is an attempt to fix this by changing the EFI memory descriptor
type into EFI_LOADER_DATA.  This type is the same type used for the kernel
data and for initramfs.  In the secondary kernel we then handle the ELF
core header data the same way as we handle the initramfs image.

This patch contains the kernel changes to make this happen.  Pretty
straightforward, we reserve the area in reserve_memory().  The address for
the area comes from the kernel command line and the size comes from the
specialized EFI parsing function vmcore_find_descriptor_size().

The kexec-tools-testing code for this can be found here:
http://lists.osdl.org/pipermail/fastboot/2007-February/005983.html

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
Cc: Simon Horman <horms@verge.net.au>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Vivek Goyal <vgoyal@in.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/efi.c     |   30 ++++++++++++++++++++++++++++++
 arch/ia64/kernel/setup.c   |   30 ++++++++++++++++++++++++++++++
 include/asm-ia64/meminit.h |    6 +++++-
 3 files changed, 65 insertions(+), 1 deletion(-)

diff -puN arch/ia64/kernel/efi.c~ia64-kexec-use-efi_loader_data-for-elf-core-header arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c~ia64-kexec-use-efi_loader_data-for-elf-core-header
+++ a/arch/ia64/kernel/efi.c
@@ -1183,3 +1183,33 @@ kdump_find_rsvd_region (unsigned long si
   return ~0UL;
 }
 #endif
+
+#ifdef CONFIG_PROC_VMCORE
+/* locate the size find a the descriptor at a certain address */
+unsigned long
+vmcore_find_descriptor_size (unsigned long address)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+	unsigned long ret = 0;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (efi_wb(md) && md->type = EFI_LOADER_DATA
+		    && md->phys_addr = address) {
+			ret = efi_md_size(md);
+			break;
+		}
+	}
+
+	if (ret = 0)
+		printk(KERN_WARNING "Cannot locate EFI vmcore descriptor\n");
+
+	return ret;
+}
+#endif
diff -puN arch/ia64/kernel/setup.c~ia64-kexec-use-efi_loader_data-for-elf-core-header arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c~ia64-kexec-use-efi_loader_data-for-elf-core-header
+++ a/arch/ia64/kernel/setup.c
@@ -250,6 +250,12 @@ reserve_memory (void)
 	}
 #endif
 
+#ifdef CONFIG_PROC_VMCORE
+	if (reserve_elfcorehdr(&rsvd_region[n].start,
+			       &rsvd_region[n].end) = 0)
+		n++;
+#endif
+
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
 
@@ -452,6 +458,30 @@ static int __init parse_elfcorehdr(char 
 	return 0;
 }
 early_param("elfcorehdr", parse_elfcorehdr);
+
+int __init reserve_elfcorehdr(unsigned long *start, unsigned long *end)
+{
+	unsigned long length;
+
+	/* We get the address using the kernel command line,
+	 * but the size is extracted from the EFI tables.
+	 * Both address and size are required for reservation
+	 * to work properly.
+	 */
+
+	if (elfcorehdr_addr >= ELFCORE_ADDR_MAX)
+		return -EINVAL;
+
+	if ((length = vmcore_find_descriptor_size(elfcorehdr_addr)) = 0) {
+		elfcorehdr_addr = ELFCORE_ADDR_MAX;
+		return -EINVAL;
+	}
+
+	*start = (unsigned long)__va(elfcorehdr_addr);
+	*end = *start + length;
+	return 0;
+}
+
 #endif /* CONFIG_PROC_VMCORE */
 
 void __init
diff -puN include/asm-ia64/meminit.h~ia64-kexec-use-efi_loader_data-for-elf-core-header include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h~ia64-kexec-use-efi_loader_data-for-elf-core-header
+++ a/include/asm-ia64/meminit.h
@@ -17,10 +17,11 @@
  * 	- kernel code & data
  * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
+ * 	- ELF core header
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 7
+#define IA64_MAX_RSVD_REGIONS 8
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
@@ -36,6 +37,9 @@ extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
 extern void efi_memmap_init(unsigned long *, unsigned long *);
 
+extern unsigned long vmcore_find_descriptor_size(unsigned long address);
+extern int reserve_elfcorehdr(unsigned long *start, unsigned long *end);
+
 /*
  * For rounding an address to the next IA64_GRANULE_SIZE or order
  */
_
