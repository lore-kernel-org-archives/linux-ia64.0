From: Jack Steiner <steiner@sgi.com>
Date: Thu, 22 Mar 2001 17:49:15 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Jack-
> 
> I was working on this and discovered the same two problems you ran
> into.  The alignment issue isn't really a problem, turns out that
> where that directive is give the code is appropriately aligned
> already so just remove the line should be OK.
> 
> The bitmap in `scsi_dma.c' is the real issue and needs to be re-written
> in a more general fashion.  I don't really have time to work on this
> right now so if you're interested go for it.  I'd be interested in
> hearing about anything you find out.
> 

I took a look at scsi_dma.c. As you pointed out, changing it to work with 
64K pages overflows the bitmap/page (128 bits). 

Fixing this is a little more than I wanted to bite off right now so I took 
an interim approach that may be "good enough" for a while - at least until
someone has more time to invest here. 

It is relatively simple to change scsi_dma.c so that 
	1) it uses longs to represent the free bit map for a page
	2) each bit represents 1024 bytes instead of 512 bytes.

A request to allocate 512 bytes will actually get a 1024 byte chunk.

With this change (& a bunch more), I have been able to boot & run
numerous tests with 64K pages. The only thing not working yet
is swapping (next on my list).




Do you feel that this is an acceptible interim solution.

The scsi_dma.c. patch is appended:


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com





diff -Naur linux_base/drivers/scsi/scsi_dma.c linux/drivers/scsi/scsi_dma.c
--- linux_base/drivers/scsi/scsi_dma.c	Mon Mar 12 13:17:38 2001
+++ linux/drivers/scsi/scsi_dma.c	Tue Mar 20 16:35:27 2001
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

