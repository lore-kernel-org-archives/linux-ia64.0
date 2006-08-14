From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 14 Aug 2006 06:57:07 +0000
Subject: IA64 Kdump patch clone ia64_boot_param area for crash kernel
Message-Id: <1155538627.2585.56.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


make a clone of ia64_boot_param area to the crash kernel.

without this patch, crash tool will not able to analyze efi memmap of
first kernel from vmcore file.
This patch is against kexec-tools-1.101 with kdump10 patch.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c kexec-tools-1.101-fix/kexec/arch/ia64/kexec-elf-ia64.c
--- kexec-tools-1.101/kexec/arch/ia64/kexec-elf-ia64.c	2006-08-05 07:32:19.000000000 +0800
+++ kexec-tools-1.101-fix/kexec/arch/ia64/kexec-elf-ia64.c	2006-08-05 07:36:49.000000000 +0800
@@ -115,9 +115,10 @@ int elf_ia64_load(int argc, char **argv,
 	unsigned long entry, max_addr, gp_value;
 	unsigned long command_line_base, ramdisk_base;
 	unsigned long efi_memmap_base, efi_memmap_size;
+	unsigned long boot_param_base;
 	int result;
 	int opt;
-	char *efi_memmap_buf;
+	char *efi_memmap_buf, *boot_param;
 #define OPT_APPEND	(OPT_ARCH_MAX+0)
 #define OPT_RAMDISK	(OPT_ARCH_MAX+1)
 	static const struct option options[] = {
@@ -191,6 +192,13 @@ int elf_ia64_load(int argc, char **argv,
 				&command_line) < 0)
 		return -1;
 
+	// reverve 4k for ia64_boot_param
+	boot_param = xmalloc(4096);
+        boot_param_base = add_buffer(info, boot_param, 4096, 4096, 4096, 0,
+                        max_addr, -1);
+        elf_rel_set_symbol(&info->rhdr, "__boot_param_base",
+                        &boot_param_base, sizeof(long));
+
 	// reserve 8k for efi_memmap
 	efi_memmap_size = 1UL<<14;
 	efi_memmap_buf = xmalloc(efi_memmap_size);
diff -Nraup kexec-tools-1.101/purgatory/arch/ia64/entry.S kexec-tools-1.101-fix/purgatory/arch/ia64/entry.S
--- kexec-tools-1.101/purgatory/arch/ia64/entry.S	2006-08-05 07:32:19.000000000 +0800
+++ kexec-tools-1.101-fix/purgatory/arch/ia64/entry.S	2006-08-05 07:37:31.000000000 +0800
@@ -46,6 +46,8 @@ purgatory_start:
 	br.call.sptk.many b0=ia64_env_setup
 	movl r10=__kernel_entry;;
 	ld8 r14=[r10];;
+	movl r10=__boot_param_base;;
+	ld8 r28=[r10];;
 	mov b6=r14;;
 	mov ar.lc=r0
 	mov ar.ec=r0
@@ -61,6 +63,7 @@ DECLARE_DATA8(__command_line)
 DECLARE_DATA8(__command_line_len)
 DECLARE_DATA8(__efi_memmap_base)
 DECLARE_DATA8(__efi_memmap_size)
+DECLARE_DATA8(__boot_param_base)
 DECLARE_DATA8(__loaded_segments)
 DECLARE_DATA8(__loaded_segments_num)
 
diff -Nraup kexec-tools-1.101/purgatory/arch/ia64/purgatory-ia64.c kexec-tools-1.101-fix/purgatory/arch/ia64/purgatory-ia64.c
--- kexec-tools-1.101/purgatory/arch/ia64/purgatory-ia64.c	2006-08-05 07:32:19.000000000 +0800
+++ kexec-tools-1.101-fix/purgatory/arch/ia64/purgatory-ia64.c	2006-08-05 07:37:22.000000000 +0800
@@ -123,11 +123,12 @@ struct kexec_boot_params {
 	uint64_t command_line_len;
 	uint64_t efi_memmap_base;
 	uint64_t efi_memmap_size;
+	uint64_t boot_param_base;
 	struct loaded_segment *loaded_segments;
 	unsigned long loaded_segments_num;
 };
 
-void
+void 
 setup_arch(void)
 {
 	reset_vga();
@@ -138,11 +139,11 @@ inline unsigned long PA(unsigned long ad
 	return addr - PAGE_OFFSET;
 }
 
-void
-patch_efi_memmap(struct kexec_boot_params *params,
+void 
+patch_efi_memmap(struct kexec_boot_params *params, 
 		struct ia64_boot_param *boot_param)
 {
-	void *dest = (void *)params->efi_memmap_base;
+	void *dest = (void *)params->efi_memmap_base; 
 	void *src  = (void *)boot_param->efi_memmap;
 	unsigned long len = boot_param->efi_memmap_size;
 	unsigned long memdesc_size = boot_param->efi_memdesc_size;
@@ -150,15 +151,15 @@ patch_efi_memmap(struct kexec_boot_param
 	efi_memory_desc_t *md1, *md2;
 	void *p1, *p2, *src_end = src + len;
 	int i;
-	for (p1 = src, p2 = dest; p1 < src_end;
+	for (p1 = src, p2 = dest; p1 < src_end; 
 			p1 += memdesc_size, p2 += memdesc_size) {
 		unsigned long mstart, mend;
 		md1 = p1;
 		md2 = p2;
-		if (md1->num_pages = 0)
+		if (md1->num_pages = 0) 
 			continue;
 		mstart = md1->phys_addr;
-		mend = md1->phys_addr + (md1->num_pages
+		mend = md1->phys_addr + (md1->num_pages 
 				<< EFI_PAGE_SHIFT);
 		switch (md1->type) {
 			case EFI_LOADER_DATA:
@@ -168,7 +169,7 @@ patch_efi_memmap(struct kexec_boot_param
 			default:
 				*md2 = *md1;
 		}
-		// segments are already sorted and aligned to 4K
+		// segments are already sorted and aligned to 4K 
 		orig_type = md2->type;
 		for (i = 0; i < params->loaded_segments_num; i++) {
 			struct loaded_segment *seg;
@@ -177,50 +178,50 @@ patch_efi_memmap(struct kexec_boot_param
 				unsigned long start_pages, mid_pages, end_pages;
 				if (seg->end > mend) {
 					p1 += memdesc_size;
-					for(; p1 < src_end;
+					for(; p1 < src_end; 
 							p1 += memdesc_size) {
 						md1 = p1;
 						/* TODO check contig and attribute here */
-						mend = md1->phys_addr
+						mend = md1->phys_addr 
 							+ (md1->num_pages << EFI_PAGE_SHIFT);
 						if (seg->end < mend)
 							break;
 					}
 				}
-				start_pages = (seg->start - mstart)
+				start_pages = (seg->start - mstart) 
 					>> EFI_PAGE_SHIFT;
 				mid_pages = (seg->end - seg->start)
 					>> EFI_PAGE_SHIFT;
-				end_pages  = (mend - seg->end)
+				end_pages  = (mend - seg->end) 
 					>> EFI_PAGE_SHIFT;
 				if (start_pages) {
 					md2->num_pages = start_pages;
-					p2 += memdesc_size;
+					p2 += memdesc_size; 
 					md2 = p2;
 					*md2 = *md1;
 				}
 				md2->phys_addr = seg->start;
 				md2->num_pages = mid_pages;
-				md2->type = seg->reserved ?
+				md2->type = seg->reserved ? 
 					EFI_UNUSABLE_MEMORY:EFI_LOADER_DATA;
 				if (end_pages) {
-					p2 += memdesc_size;
+					p2 += memdesc_size; 
 					md2 = p2;
 					*md2 = *md1;
 					md2->phys_addr = seg->end;
 					md2->num_pages = end_pages;
 					md2->type = orig_type;
 					mstart = seg->end;
-				} else
+				} else 
 					break;
 			}
 		}
 	}
-
+	
 	boot_param->efi_memmap_size = p2 - dest;
 }
 
-void
+void 
 flush_icache_range(char *start, unsigned long len)
 {
 	unsigned long i;
@@ -233,7 +234,7 @@ flush_icache_range(char *start, unsigned
 extern char __dummy_efi_function[], __dummy_efi_function_end[];
 
 
-void
+void 
 ia64_env_setup(struct ia64_boot_param *boot_param,
 	struct kexec_boot_params *params)
 {
@@ -243,13 +244,15 @@ ia64_env_setup(struct ia64_boot_param *b
 	unsigned long *set_virtual_address_map;
 	char *command_line = (char *)params->command_line;
 	uint64_t command_line_len = params->command_line_len;
-
+	struct ia64_boot_param *new_boot_param = 
+	(struct ia64_boot_param *) params->boot_param_base;
+	memcpy(new_boot_param, boot_param, 4096);
 	// patch efi_runtime->set_virtual_address_map to a
 	// dummy function
 	len = __dummy_efi_function_end - __dummy_efi_function;
-	memcpy(command_line + command_line_len,
+	memcpy(command_line + command_line_len, 
 		__dummy_efi_function, len);
-	systab = (efi_system_table_t *)boot_param->efi_systab;
+	systab = (efi_system_table_t *)new_boot_param->efi_systab;
 	runtime = (efi_runtime_services_t *)PA(systab->runtime);
 	set_virtual_address_map  		(unsigned long *)PA(runtime->set_virtual_address_map);
@@ -257,15 +260,14 @@ ia64_env_setup(struct ia64_boot_param *b
 		(unsigned long)(command_line + command_line_len);
 	flush_icache_range(command_line + command_line_len, len);
 
-	patch_efi_memmap(params, boot_param);
-
-	boot_param->efi_memmap = params->efi_memmap_base;
+	patch_efi_memmap(params, new_boot_param);
 
-	boot_param->command_line = params->command_line;
-	boot_param->console_info.orig_x = 0;
-	boot_param->console_info.orig_y = 0;
-	boot_param->initrd_start = params->ramdisk_base;
-	boot_param->initrd_size =  params->ramdisk_size;
+	new_boot_param->efi_memmap = params->efi_memmap_base;
+	new_boot_param->command_line = params->command_line;
+	new_boot_param->console_info.orig_x = 0;
+	new_boot_param->console_info.orig_y = 0;
+	new_boot_param->initrd_start = params->ramdisk_base;
+	new_boot_param->initrd_size =  params->ramdisk_size;
 }
 
 /* This function can be used to execute after the SHA256 verification. */

