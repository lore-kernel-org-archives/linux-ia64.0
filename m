From: Bill Nottingham <notting@redhat.com>
Date: Thu, 01 Jun 2000 21:19:28 +0000
Subject: [Linux-ia64] initrd suport for ELI, kernel
MIME-Version: 1
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Message-Id: <marc-linux-ia64-105590678205112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's some patches that add initrd support to ELI
and the kernel. To use, simply add:

	initrd=<some file>
	
to your eli.cfg. The ELI code that loads the kernel is
shamelessly copied from the kernel loading code. This
currently loads the initrd directly after the kernel.

Current bugs:
 - the kernel assumes the address passed to it for
   the initrd is valid. We should probably check this.
   
Bill

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eli-initrd.diff"

diff -ru eli-0.3.0-old/eli.c eli-0.3.0/eli.c
--- eli-0.3.0-old/eli.c	Thu Mar  2 15:56:24 2000
+++ eli-0.3.0/eli.c	Tue May 30 16:43:30 2000
@@ -64,6 +64,8 @@
 	struct vector *vectors;		/* physical address of vector table */
 
 	fpswa_interface_t *efi_fpswa;	/* the fpswa interface which contains the revision and a physical pointer to the FPSWA function  */
+	UINT64 initrd_start;
+	UINT64 initrd_size;
 };
 
 #define MAX_IMAGE_NAME	15
@@ -76,6 +78,7 @@
 	CHAR16	*filename;
 	CHAR16	*append;
 	CHAR16	*root;
+	CHAR16	*initrd;
 };
 
 struct boot_image *image_head = NULL, *image_tail = NULL, *default_image = NULL;
@@ -268,6 +271,9 @@
 				image->root = StrDuplicate(aToU(p2));
 			else
 				root = StrDuplicate(aToU(p2));
+		} else if (strncmpa(p1, "initrd",6) == 0) {
+			if (image)
+				image->initrd = StrDuplicate(aToU(p2));
 		} else if (strncmpa(p1, "read-only", 9) == 0) {
 			readonly = 1;
 		} else if (strncmpa(p1, "read-write", 10) == 0) {
@@ -308,7 +314,110 @@
 }
 
 INTN
-load_elf (EFI_FILE_HANDLE fs, CHAR16 *filename, EFI_SYSTEM_TABLE *systab, UINT64 *start_addr)
+load_ramdisk (EFI_FILE_HANDLE fs, CHAR16 *filename, EFI_SYSTEM_TABLE *systab, UINT64 start_addr, UINT64 *initrd_size)
+{
+	EFI_FILE_HANDLE file;
+	EFI_STATUS status;
+	INTN total_size = 0, size = 0;
+	UINTN pages;
+	EFI_FILE_INFO *initrd_info;
+	
+	/* 
+	 * Reset the input interface, is this needed?
+	 * I think this is a bug in the 10/20/99 release of EFI.
+	 * but it seems to fix the problem with ReadKeyStroke() becoming
+	 * blocking !
+	 */
+	systab->ConIn->Reset(systab->ConIn, 1);
+
+	/* Open the file */
+	status = fs->Open(fs, &file, filename, EFI_FILE_MODE_READ, EFI_FILE_READ_ONLY);
+	if (EFI_ERROR(status)) {
+		Print(W2U(L"%s: open failed: %r\n"), filename, status);
+		return EFI_LOAD_ERROR;
+	}
+
+#ifdef DEBUG
+	Print(W2U(L"Open %s worked\n"), filename);
+#endif
+		
+	initrd_info = LibFileInfo(file);
+	if (!initrd_info) {
+		Print(W2U(L"%s: couldn't read file info\n"),filename);
+		return EFI_LOAD_ERROR;
+	}
+
+	total_size = initrd_info->FileSize;
+	*initrd_size = total_size;
+
+	/* round up to get required number of pages */
+	pages = SIZE_TO_PAGES(total_size);
+
+	/* Make Buffer point to the requested physical address in memory */
+#ifdef BROKEN_EFI_FLOPPY
+	/*
+	 * Early versions of EFI had troubles loading files
+	 * from floppies in a single big request.  Breaking
+	 * the read down into chunks of 4KB fixed that
+	 * problem.  Once EFI is fixed, this is no longer
+	 * needed.
+	 */
+	{
+		EFI_PHYSICAL_ADDRESS buffer;
+		UINTN j = 0;
+
+		buffer = virt_to_phys(start_addr);
+		while (total_size > 0) {
+			CHAR8 helicopter[4] = { '|' , '/' , '-' , '\\' };
+			int x;
+
+			size = 4 * PAGE_SIZE;
+			if (size > total_size)
+			  size = total_size;
+			status = fs->Read(file, &size, (VOID *)buffer);
+			if (EFI_ERROR(status)) {
+				Print(W2U(L"%s: read failed: %r\n"), filename, status);
+				BS->FreePages(start_addr, pages);
+				return EFI_LOAD_ERROR;
+			}
+			
+			Print(W2U(L"%c\b"), helicopter[j++%4]);
+			buffer     += size;
+			total_size -= size; 
+
+			if (check_abort(systab) == EFI_SUCCESS)
+			  goto load_abort;
+		}
+	}
+#else	
+	size = total_size;
+	status = fs->Read(file, &size, (VOID *) virt_to_phys(start_addr));
+	if (EFI_ERROR(status)) {
+		Print(W2U(L"%s: read failed: %r\n"), filename, status);
+		BS->FreePages(start_addr, pages);
+		return EFI_LOAD_ERROR;
+	}
+	Print(W2U(L"-> %ld bytes\n"), size);
+#endif		
+	fs->Close(file);
+
+	return EFI_SUCCESS;
+
+#ifdef BROKEN_EFI_FLOPPY
+load_abort:
+	Print(W2U(L"\nLoading aborted\n"));
+	status = BS->FreePages(start_addr, pages);
+	if (status != EFI_SUCCESS)
+		efi_perror(W2U(L"FreePages"), status);
+	else if (verbose)
+		Print(W2U(L"Freed %ld pages starting at 0x%lx\n"), pages, start_addr);
+	status = fs->Close(file);
+	return EFI_NOT_READY;
+#endif
+}
+
+INTN
+load_elf (EFI_FILE_HANDLE fs, CHAR16 *filename, EFI_SYSTEM_TABLE *systab, UINT64 *start_addr, UINT64 *end_addr)
 {
 	Elf64_Ehdr ehdr;
 	Elf64_Phdr phdr;
@@ -501,6 +610,7 @@
 	}
 	fs->Close(file);
 	*start_addr = ehdr.e_entry;
+        *end_addr = max_addr;
 
 	return EFI_SUCCESS;
 
@@ -649,7 +759,8 @@
  */
 static EFI_STATUS
 create_boot_params (EFI_HANDLE image, EFI_SYSTEM_TABLE *systab, CHAR16 *args,
-	struct acpi_op *acpi_root, UINT64 start_addr)
+	struct acpi_op *acpi_root, UINT64 start_addr, UINT64 initrd_start,
+		    UINT64 initrd_size)
 {
 	UINTN num_pages, cookie, desc_size, cols, rows, args_size, map_size = 512;
 	SIMPLE_TEXT_OUTPUT_INTERFACE *conout;
@@ -744,6 +855,8 @@
 
 	bp->num_vectors = num_vectors;
 	bp->vectors = vectors;
+	bp->initrd_start = initrd_start;
+	bp->initrd_size = initrd_size;
 
 	/* fetch console parameters: */
 	conout = systab->ConOut;
@@ -970,6 +1083,9 @@
 	EFI_FILE_HANDLE fs;
 	EFI_STATUS status;
 	UINT64 start_addr;
+	UINT64 end_addr;
+	UINT64 initrd_start = 0;
+	UINT64 initrd_size = 0;
 	UINTN argc, i;
 	CHAR16 *argv[MAX_ARGS];
 	struct boot_image *boot_image;
@@ -1107,7 +1223,7 @@
 	Print(W2U(L"eli: booting `%s' with args=`%s' "), kernel_name, args);
 #endif
 
-	switch (load_elf(fs, kernel_name, systab, &start_addr)) {
+	switch (load_elf(fs, kernel_name, systab, &start_addr, &end_addr)) {
 		case EFI_SUCCESS:
 			break;
 
@@ -1118,9 +1234,20 @@
 		case EFI_LOAD_ERROR:
 			return EFI_LOAD_ERROR;
 	}
+	if (boot_image && boot_image->initrd) {
+		end_addr = (end_addr/PAGE_SIZE+1) * PAGE_SIZE;
+		switch (load_ramdisk(fs, boot_image->initrd, systab, end_addr, &initrd_size)) {
+		 case  EFI_SUCCESS:
+			initrd_start = end_addr;
+			break;
+		case EFI_OUT_OF_RESOURCES:
+		case EFI_LOAD_ERROR:
+			return EFI_LOAD_ERROR;
+		}
+	}
 
 	/* No console output permitted after create_boot_params()! */
-	status = create_boot_params(image, systab, args, acpi_root, start_addr);
+	status = create_boot_params(image, systab, args, acpi_root, start_addr, initrd_start, initrd_size);
 	if (status != EFI_SUCCESS)
 		return status;
 	start_kernel(start_addr);

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="kernel-initrd.diff"

diff -ru redhat/BUILD/linux/arch/ia64/kernel/setup.c lfoo/arch/ia64/kernel/setup.c
--- redhat/BUILD/linux/arch/ia64/kernel/setup.c	Tue May 30 16:32:59 2000
+++ lfoo/arch/ia64/kernel/setup.c	Tue May 30 16:36:18 2000
@@ -26,6 +26,9 @@
 #include <linux/string.h>
 #include <linux/threads.h>
 #include <linux/console.h>
+#ifdef CONFIG_BLK_DEV_RAM
+#include <linux/blk.h>
+#endif
 
 #include <asm/acpi-ext.h>
 #include <asm/page.h>
@@ -125,11 +128,24 @@
 	 * change APIs, they'd do things for the better.  Grumble...
 	 */
 	bootmap_start = PAGE_ALIGN(__pa(&_end));
+	if (ia64_boot_param.initrd_size) {
+		bootmap_start = PAGE_ALIGN(bootmap_start+ia64_boot_param.initrd_size);
+	}
 	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
 
 	efi_memmap_walk(free_available_memory, 0);
 
 	reserve_bootmem(bootmap_start, bootmap_size);
+#ifdef CONFIG_BLK_DEV_INITRD
+	initrd_start = ia64_boot_param.initrd_start;
+	if (initrd_start) {
+		initrd_end = initrd_start+ia64_boot_param.initrd_size;
+		printk("Initial ramdisk at: 0x%p (%lu bytes)\n",
+		       (void *) initrd_start, ia64_boot_param.initrd_size);
+		reserve_bootmem(virt_to_phys(initrd_start),
+		 		ia64_boot_param.initrd_size);
+	}
+#endif
 #if 0
 	/* XXX fix me */
 	init_mm.start_code = (unsigned long) &_stext;
diff -ru redhat/BUILD/linux/arch/ia64/mm/init.c lfoo/arch/ia64/mm/init.c
--- redhat/BUILD/linux/arch/ia64/mm/init.c	Tue May 30 16:32:59 2000
+++ lfoo/arch/ia64/mm/init.c	Wed May 24 22:05:11 2000
@@ -179,6 +180,19 @@
 	}
 	printk ("Freeing unused kernel memory: %ldkB freed\n",
 		(&__init_end - &__init_begin) >> 10);
+}
+
+void
+free_initrd_mem(unsigned long start, unsigned long end)
+{
+	if (start < end)
+	  	printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
+	for (; start < end; start += PAGE_SIZE) {
+		clear_bit(PG_reserved, &mem_map[MAP_NR(start)].flags);
+		set_page_count(&mem_map[MAP_NR(start)], 1);
+		free_page(start);
+		++totalram_pages;
+	}
 }
 
 void
diff -ru redhat/BUILD/linux/include/asm-ia64/system.h lfoo/include/asm-ia64/system.h
--- redhat/BUILD/linux/include/asm-ia64/system.h	Tue May 30 16:33:01 2000
+++ lfoo/include/asm-ia64/system.h	Thu May 25 16:47:59 2000
@@ -54,6 +54,8 @@
 	__u16 num_pci_vectors;	/* number of ACPI derived PCI IRQ's*/
 	__u64 pci_vectors;	/* physical address of PCI data (pci_vector_struct)*/
 	__u64 fpswa;		/* physical address of the the fpswa interface */
+	__u64 initrd_start;
+	__u64 initrd_size;
 } ia64_boot_param;
 
 extern inline void

--GvXjxJ+pjyke8COw--


