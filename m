From: Jack Steiner <steiner@sgi.com>
Date: Mon, 26 Mar 2001 17:51:07 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005352@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have built a system with 64K pages. 

As long as you do not try mount swap devices, everything 
seems to be running ok.  (Swapping to files works OK).

I ran fairly heavy stress for a couple hours
and did not see any failures. More testing is still needed, however.


There are still a few issues with swapping to devices. The  
buffer_head field "b_size" is a short, the kernel tries to
do 64K IO & overflows the field. (I'm assuming that changing
b_size to an "int" is NOT acceptible). 

I'm working on fixing this but thought I'd send these fixes out now
since they enable others to use 64K pages.



Here is a summary of the changes I've made so far:

  include/asm-ia64/system.h
  	add BOOT_PARAM_ADDR. If pagesize is 64K, BOOT_PARAM_ADDR. is not
	the same as ZERO_PAGE_ADDR.

  arch/ia64/boot/bootloader.c
  	change name of ZERO_PAGE_ADDR to BOOT_PARAM_ADDR

  arch/ia64/kernel/fw-emu.c
  	change name of ZERO_PAGE_ADDR to BOOT_PARAM_ADDR

  arch/ia64/kernel/gate.S
  	delete ".align PAGE_SIZE". Code is already correctly aligned & 
	gcc doesnt support alignment > 16k

  arch/ia64/kernel/ivt.S
  	add alignment pragmas to the end to make the size of the IVT
	an integral number of pages. 

  arch/ia64/kernel/setup.c
  	change name of ZERO_PAGE_ADDR to BOOT_PARAM_ADDR

  arch/ia64/sn/fprom/fw-emu.c
	change name of ZERO_PAGE_ADDR to BOOT_PARAM_ADDR

  drivers/scsi/scsi_dma.c
  	change the FreeSectorBitmap so that on 64k page systems, a bit
	in the map represents 1K instead of 512 bytes. Otherwise, you
	overflow the long used to manage free space in a page.
	I view this as an interim fix..... (I swapped mail with dugger
	about this patch).

  include/asm-ia64/a.out.h
  	dont make STACK_TOP bigger than the max virtual address supported 
	on itanium.



	

diff -Naur linux_base/arch/ia64/boot/bootloader.c linux/arch/ia64/boot/bootloader.c
--- linux_base/arch/ia64/boot/bootloader.c	Thu Mar 15 08:24:13 2001
+++ linux/arch/ia64/boot/bootloader.c	Tue Mar 20 21:37:45 2001
@@ -224,11 +224,11 @@
 	ssc(0, (long) kpath, 0, 0, SSC_LOAD_SYMBOLS);
 
 	/*
-	 * Install the kernel's command line argument on ZERO_PAGE
-	 * just after the botoparam structure.
+	 * Install the kernel's command line argument at BOOT_PARAM_ADDR
+	 * just after the bootparam structure.
 	 * In case we don't have any argument just put \0
 	 */
-	memcpy(((struct ia64_boot_param *)ZERO_PAGE_ADDR) + 1, args, arglen);
+	memcpy(((struct ia64_boot_param *)BOOT_PARAM_ADDR) + 1, args, arglen);
 	sp = __pa(&stack);
 
 	asm volatile ("br.sptk.few %0" :: "b"(e_entry));
diff -Naur linux_base/arch/ia64/kernel/fw-emu.c linux/arch/ia64/kernel/fw-emu.c
--- linux_base/arch/ia64/kernel/fw-emu.c	Thu Mar 15 08:24:15 2001
+++ linux/arch/ia64/kernel/fw-emu.c	Tue Mar 20 16:33:52 2001
@@ -469,7 +469,7 @@
 	md->attribute = EFI_MEMORY_WB;
 #endif
 
-	bp = id(ZERO_PAGE_ADDR);
+	bp = id(BOOT_PARAM_ADDR);
 	bp->efi_systab = __pa(&fw_mem);
 	bp->efi_memmap = __pa(efi_memmap);
 	bp->efi_memmap_size = NUM_MEM_DESCS*sizeof(efi_memory_desc_t);
diff -Naur linux_base/arch/ia64/kernel/gate.S linux/arch/ia64/kernel/gate.S
--- linux_base/arch/ia64/kernel/gate.S	Mon Mar 19 09:55:02 2001
+++ linux/arch/ia64/kernel/gate.S	Mon Mar 19 13:12:38 2001
@@ -19,8 +19,6 @@
 
 	.section .text.gate,"ax"
 
-	.align PAGE_SIZE
-
 #	define SIGINFO_OFF	16
 #	define SIGCONTEXT_OFF	(SIGINFO_OFF + ((IA64_SIGINFO_SIZE + 15) & ~15))
 #	define FLAGS_OFF	IA64_SIGCONTEXT_FLAGS_OFFSET
diff -Naur linux_base/arch/ia64/kernel/ivt.S linux/arch/ia64/kernel/ivt.S
--- linux_base/arch/ia64/kernel/ivt.S	Fri Mar 16 09:21:13 2001
+++ linux/arch/ia64/kernel/ivt.S	Tue Mar 20 21:37:34 2001
@@ -1357,3 +1357,20 @@
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x7f00 Entry 67 (size 16 bundles) Reserved
 	FAULT(67)
+
+
+//
+// The end of the IVT must be aligned at a page boundary so that the structures
+// that follow it are also aligned on page boundaries. We would like to use the
+// gcc .align pragma but that doesnt work for sizes greater than 16K alignment
+// and we may need 64K alignment. For now, the following works. If/when gcc is
+// fixed, this should be revisited.....
+//
+#ifdef CONFIG_IA64_PAGE_SIZE_64KB
+        .align 16384
+        nop 0;;
+        .align 16384
+        nop 0;;
+        .align 16384
+#endif
+
diff -Naur linux_base/arch/ia64/kernel/setup.c linux/arch/ia64/kernel/setup.c
--- linux_base/arch/ia64/kernel/setup.c	Thu Mar 15 08:24:15 2001
+++ linux/arch/ia64/kernel/setup.c	Tue Mar 20 16:32:28 2001
@@ -143,10 +143,11 @@
 
 	/*
 	 * The secondary bootstrap loader passes us the boot
-	 * parameters at the beginning of the ZERO_PAGE, so let's
+	 * parameters at the end of the 32K IVT. Depending on pagesize,
+	 * this may be the location of the ZERO_PAGE, so let's
 	 * stash away those values before ZERO_PAGE gets cleared out.
 	 */
-	memcpy(&ia64_boot_param, (void *) ZERO_PAGE_ADDR, sizeof(ia64_boot_param));
+	memcpy(&ia64_boot_param, (void *) BOOT_PARAM_ADDR, sizeof(ia64_boot_param));
 
 	*cmdline_p = __va(ia64_boot_param.command_line);
 	strncpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
diff -Naur linux_base/arch/ia64/sn/fprom/fw-emu.c linux/arch/ia64/sn/fprom/fw-emu.c
--- linux_base/arch/ia64/sn/fprom/fw-emu.c	Thu Mar 15 08:24:16 2001
+++ linux/arch/ia64/sn/fprom/fw-emu.c	Tue Mar 20 16:32:19 2001
@@ -494,7 +494,7 @@
 	md = &efi_memmap[0];
 	num_memmd = build_efi_memmap((void *)md, mdsize) ;
 
-	bp = id(ZERO_PAGE_ADDR + (((long)base_nasid)<<33));
+	bp = id(BOOT_PARAM_ADDR + (((long)base_nasid)<<33));
 	bp->efi_systab = __fwtab_pa(base_nasid, &fw_mem);
 	bp->efi_memmap = __fwtab_pa(base_nasid, efi_memmap);
 	bp->efi_memmap_size = num_memmd*mdsize;
diff -Naur linux_base/drivers/scsi/scsi_dma.c linux/drivers/scsi/scsi_dma.c
--- linux_base/drivers/scsi/scsi_dma.c	Mon Mar 19 09:55:02 2001
+++ linux/drivers/scsi/scsi_dma.c	Tue Mar 20 16:37:37 2001
@@ -23,13 +23,25 @@
  * PAGE_SIZE must be a multiple of the sector size (512).  True
  * for all reasonably recent architectures (even the VAX...).
  */
-#define SECTOR_SIZE		512
+#ifdef CONFIG_IA64_PAGE_SIZE_64KB
+#define BIG_SECTORS
+#endif
+
+#ifdef BIG_SECTORS
+#define SECTOR_SHIFT		10
+#else
+#define SECTOR_SHIFT		9
+#endif
+
+#define SECTOR_SIZE		(1<<SECTOR_SHIFT)
 #define SECTORS_PER_PAGE	(PAGE_SIZE/SECTOR_SIZE)
 
 #if SECTORS_PER_PAGE <= 8
 typedef unsigned char FreeSectorBitmap;
 #elif SECTORS_PER_PAGE <= 32
 typedef unsigned int FreeSectorBitmap;
+#elif SECTORS_PER_PAGE <= 64
+typedef unsigned long FreeSectorBitmap;
 #else
 #error You lose.
 #endif
@@ -75,10 +87,14 @@
 	unsigned long flags;
 
 	int i, j;
+#ifdef BIG_SECTORS
+	if (len % SECTOR_SIZE)
+		len += 512;
+#endif
 	if (len % SECTOR_SIZE != 0 || len > PAGE_SIZE)
 		return NULL;
 
-	nbits = len >> 9;
+	nbits = len >> SECTOR_SHIFT;
 	mask = (1 << nbits) - 1;
 
 	spin_lock_irqsave(&allocator_request_lock, flags);
@@ -89,11 +105,11 @@
 				dma_malloc_freelist[i] |= (mask << j);
 				scsi_dma_free_sectors -= nbits;
 #ifdef DEBUG
-				SCSI_LOG_MLQUEUE(3, printk("SMalloc: %d %p [From:%p]\n", len, dma_malloc_pages[i] + (j << 9)));
-				printk("SMalloc: %d %p [From:%p]\n", len, dma_malloc_pages[i] + (j << 9));
+				SCSI_LOG_MLQUEUE(3, printk("SMalloc: %d %p [From:%p]\n", len, dma_malloc_pages[i] + (j << SECTOR_SHIFT)));
+				printk("SMalloc: %d %p [From:%p]\n", len, dma_malloc_pages[i] + (j << SECTOR_SHIFT));
 #endif
 				spin_unlock_irqrestore(&allocator_request_lock, flags);
-				return (void *) ((unsigned long) dma_malloc_pages[i] + (j << 9));
+				return (void *) ((unsigned long) dma_malloc_pages[i] + (j << SECTOR_SHIFT));
 			}
 		}
 	spin_unlock_irqrestore(&allocator_request_lock, flags);
@@ -136,15 +152,19 @@
 	SCSI_LOG_MLQUEUE(3, printk("SFree: %p %d\n", obj, len));
 #endif
 
+#ifdef BIG_SECTORS
+	if (len % SECTOR_SIZE)
+		len += 512;
+#endif
 	spin_lock_irqsave(&allocator_request_lock, flags);
 
 	for (page = 0; page < dma_sectors / SECTORS_PER_PAGE; page++) {
 		unsigned long page_addr = (unsigned long) dma_malloc_pages[page];
 		if ((unsigned long) obj >= page_addr &&
 		    (unsigned long) obj < page_addr + PAGE_SIZE) {
-			sector = (((unsigned long) obj) - page_addr) >> 9;
+			sector = (((unsigned long) obj) - page_addr) >> SECTOR_SHIFT;
 
-			nbits = len >> 9;
+			nbits = len >> SECTOR_SHIFT;
 			mask = (1 << nbits) - 1;
 
 			if (sector + nbits > SECTORS_PER_PAGE)
@@ -254,27 +274,27 @@
 				if (nents < 64) nents = 64;
 #endif
 				new_dma_sectors += ((nents *
-				sizeof(struct scatterlist) + 511) >> 9) *
+				sizeof(struct scatterlist) + SECTOR_SIZE-1) >> SECTOR_SHIFT) *
 				 SDpnt->queue_depth;
 				if (SDpnt->type = TYPE_WORM || SDpnt->type = TYPE_ROM)
-					new_dma_sectors += (2048 >> 9) * SDpnt->queue_depth;
+					new_dma_sectors += (2048 >> SECTOR_SHIFT) * SDpnt->queue_depth;
 			} else if (SDpnt->type = TYPE_SCANNER ||
 				   SDpnt->type = TYPE_PROCESSOR ||
 				   SDpnt->type = TYPE_COMM ||
 				   SDpnt->type = TYPE_MEDIUM_CHANGER ||
 				   SDpnt->type = TYPE_ENCLOSURE) {
-				new_dma_sectors += (4096 >> 9) * SDpnt->queue_depth;
+				new_dma_sectors += (4096 >> SECTOR_SHIFT) * SDpnt->queue_depth;
 			} else {
 				if (SDpnt->type != TYPE_TAPE) {
 					printk("resize_dma_pool: unknown device type %d\n", SDpnt->type);
-					new_dma_sectors += (4096 >> 9) * SDpnt->queue_depth;
+					new_dma_sectors += (4096 >> SECTOR_SHIFT) * SDpnt->queue_depth;
 				}
 			}
 
 			if (host->unchecked_isa_dma &&
 			    need_isa_bounce_buffers &&
 			    SDpnt->type != TYPE_TAPE) {
-				new_dma_sectors += (PAGE_SIZE >> 9) * host->sg_tablesize *
+				new_dma_sectors += (PAGE_SIZE >> SECTOR_SHIFT) * host->sg_tablesize *
 				    SDpnt->queue_depth;
 				new_need_isa_buffer++;
 			}
diff -Naur linux_base/include/asm-ia64/a.out.h linux/include/asm-ia64/a.out.h
--- linux_base/include/asm-ia64/a.out.h	Thu Mar 15 08:30:28 2001
+++ linux/include/asm-ia64/a.out.h	Mon Mar 19 14:05:34 2001
@@ -30,7 +30,11 @@
 #define N_TXTOFF(x)	0
 
 #ifdef __KERNEL__
+#ifdef CONFIG_IA64_PAGE_SIZE_64KB
+# define STACK_TOP	(0x8000000000000000UL + (1UL << 50))
+#else
 # define STACK_TOP	(0x8000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)))
+#endif
 # define IA64_RBS_BOT	(STACK_TOP - 0x80000000L)	/* bottom of register backing store */
 #endif
 
diff -Naur linux_base/include/asm-ia64/system.h linux/include/asm-ia64/system.h
--- linux_base/include/asm-ia64/system.h	Thu Mar 22 18:27:40 2001
+++ linux/include/asm-ia64/system.h	Thu Mar 22 18:00:49 2001
@@ -17,13 +17,19 @@
 #include <asm/page.h>
 
 #define KERNEL_START		(PAGE_OFFSET + 0x500000)
+#define BOOT_PARAM_ADDR		(KERNEL_START + 0x8000)
 
 /*
  * The following #defines must match with vmlinux.lds.S:
  */
-#define IVT_END_ADDR		(KERNEL_START + 0x8000)
-#define ZERO_PAGE_ADDR		(IVT_END_ADDR + 0*PAGE_SIZE)
-#define SWAPPER_PGD_ADDR	(IVT_END_ADDR + 1*PAGE_SIZE)
+#ifdef CONFIG_IA64_PAGE_SIZE_64KB
+#define IVT_PAGE_END_ADDR	(KERNEL_START + 0x10000)
+#else
+#define IVT_PAGE_END_ADDR	(KERNEL_START + 0x8000)
+#endif
+
+#define ZERO_PAGE_ADDR		(IVT_PAGE_END_ADDR + 0*PAGE_SIZE)
+#define SWAPPER_PGD_ADDR	(IVT_PAGE_END_ADDR + 1*PAGE_SIZE)
 
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
 #define PERCPU_ADDR		(0xa000000000000000 + 2*PAGE_SIZE)
-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


