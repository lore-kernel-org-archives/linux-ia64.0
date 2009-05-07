From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 07 May 2009 04:35:48 +0000
Subject: [PATCH -tip 5/5] dma-debug: fix compiler warnings on IA64
Message-Id: <1241670948-5818-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Joerg Roedel <joerg.roedel@amd.com>

lib/dma-debug.c: In function 'debug_dma_dump_mappings':
lib/dma-debug.c:233: warning: format '%Lx' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:233: warning: format '%Lx' expects type 'long long unsigned int', but argument 8 has type 'u64'
lib/dma-debug.c: In function 'check_unmap':
lib/dma-debug.c:553: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:553: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:561: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:561: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:561: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
lib/dma-debug.c:569: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:569: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:577: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:577: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:598: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:598: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c: In function 'check_for_illegal_area':
lib/dma-debug.c:634: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c: In function 'check_sync':
lib/dma-debug.c:657: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:665: warning: format '%016llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
lib/dma-debug.c:665: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:665: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
lib/dma-debug.c:665: warning: format '%llu' expects type 'long long unsigned int', but argument 9 has type 'u64'
lib/dma-debug.c:674: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:688: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
lib/dma-debug.c:698: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Joerg Roedel <joerg.roedel@amd.com>
---
 lib/dma-debug.c |   82 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 48 insertions(+), 34 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index cdd205d..14e0fc2 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -234,7 +234,8 @@ void debug_dma_dump_mappings(struct device *dev)
 					 "%s idx %d P=%Lx D=%Lx L=%Lx %s\n",
 					 type2name[entry->type], idx,
 					 (unsigned long long)entry->paddr,
-					 entry->dev_addr, entry->size,
+					 (unsigned long long)entry->dev_addr,
+					 (unsigned long long)entry->size,
 					 dir2name[entry->direction]);
 			}
 		}
@@ -553,7 +554,8 @@ static void check_unmap(struct dma_debug_entry *ref)
 		err_printk(ref->dev, NULL, "DMA-API: device driver tries "
 			   "to free DMA memory it has not allocated "
 			   "[device address=0x%016llx] [size=%llu bytes]\n",
-			   ref->dev_addr, ref->size);
+			   (unsigned long long)ref->dev_addr,
+			   (unsigned long long)ref->size);
 		goto out;
 	}
 
@@ -562,7 +564,9 @@ static void check_unmap(struct dma_debug_entry *ref)
 			   "DMA memory with different size "
 			   "[device address=0x%016llx] [map size=%llu bytes] "
 			   "[unmap size=%llu bytes]\n",
-			   ref->dev_addr, entry->size, ref->size);
+			   (unsigned long long)ref->dev_addr,
+			   (unsigned long long)entry->size,
+			   (unsigned long long)ref->size);
 	}
 
 	if (ref->type != entry->type) {
@@ -570,7 +574,8 @@ static void check_unmap(struct dma_debug_entry *ref)
 			   "DMA memory with wrong function "
 			   "[device address=0x%016llx] [size=%llu bytes] "
 			   "[mapped as %s] [unmapped as %s]\n",
-			   ref->dev_addr, ref->size,
+			   (unsigned long long)ref->dev_addr,
+			   (unsigned long long)ref->size,
 			   type2name[entry->type], type2name[ref->type]);
 	} else if ((entry->type = dma_debug_coherent) &&
 		   (ref->paddr != entry->paddr)) {
@@ -578,7 +583,8 @@ static void check_unmap(struct dma_debug_entry *ref)
 			   "DMA memory with different CPU address "
 			   "[device address=0x%016llx] [size=%llu bytes] "
 			   "[cpu alloc address=%p] [cpu free address=%p]",
-			   ref->dev_addr, ref->size,
+			   (unsigned long long)ref->dev_addr,
+			   (unsigned long long)ref->size,
 			   (void *)entry->paddr, (void *)ref->paddr);
 	}
 
@@ -599,7 +605,8 @@ static void check_unmap(struct dma_debug_entry *ref)
 			   "DMA memory with different direction "
 			   "[device address=0x%016llx] [size=%llu bytes] "
 			   "[mapped with %s] [unmapped with %s]\n",
-			   ref->dev_addr, ref->size,
+			   (unsigned long long)ref->dev_addr,
+			   (unsigned long long)ref->size,
 			   dir2name[entry->direction],
 			   dir2name[ref->direction]);
 	}
@@ -632,8 +639,9 @@ static void check_for_illegal_area(struct device *dev, void *addr, u64 size)
 	if (overlap(addr, size, _text, _etext) ||
 	    overlap(addr, size, __start_rodata, __end_rodata))
 		err_printk(dev, NULL, "DMA-API: device driver maps "
-				"memory from kernel text or rodata "
-				"[addr=%p] [size=%llu]\n", addr, size);
+			   "memory from kernel text or rodata "
+			   "[addr=%p] [size=%llu]\n", addr,
+			   (unsigned long long)size);
 }
 
 static void check_sync(struct device *dev, dma_addr_t addr,
@@ -655,29 +663,33 @@ static void check_sync(struct device *dev, dma_addr_t addr,
 
 	if (!entry) {
 		err_printk(dev, NULL, "DMA-API: device driver tries "
-				"to sync DMA memory it has not allocated "
-				"[device address=0x%016llx] [size=%llu bytes]\n",
-				(unsigned long long)addr, size);
+			   "to sync DMA memory it has not allocated "
+			   "[device address=0x%016llx] [size=%llu bytes]\n",
+			   (unsigned long long)addr, (unsigned long long)size);
 		goto out;
 	}
 
 	if ((offset + size) > entry->size) {
 		err_printk(dev, entry, "DMA-API: device driver syncs"
-				" DMA memory outside allocated range "
-				"[device address=0x%016llx] "
-				"[allocation size=%llu bytes] [sync offset=%llu] "
-				"[sync size=%llu]\n", entry->dev_addr, entry->size,
-				offset, size);
+			   " DMA memory outside allocated range "
+			   "[device address=0x%016llx] "
+			   "[allocation size=%llu bytes] [sync offset=%llu] "
+			   "[sync size=%llu]\n",
+			   (unsigned long long)entry->dev_addr,
+			   (unsigned long long)entry->size,
+			   (unsigned long long)offset,
+			   (unsigned long long)size);
 	}
 
 	if (direction != entry->direction) {
 		err_printk(dev, entry, "DMA-API: device driver syncs "
-				"DMA memory with different direction "
-				"[device address=0x%016llx] [size=%llu bytes] "
-				"[mapped with %s] [synced with %s]\n",
-				(unsigned long long)addr, entry->size,
-				dir2name[entry->direction],
-				dir2name[direction]);
+			   "DMA memory with different direction "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [synced with %s]\n",
+			   (unsigned long long)addr,
+			   (unsigned long long)entry->size,
+			   dir2name[entry->direction],
+			   dir2name[direction]);
 	}
 
 	if (entry->direction = DMA_BIDIRECTIONAL)
@@ -686,22 +698,24 @@ static void check_sync(struct device *dev, dma_addr_t addr,
 	if (to_cpu && !(entry->direction = DMA_FROM_DEVICE) &&
 		      !(direction = DMA_TO_DEVICE))
 		err_printk(dev, entry, "DMA-API: device driver syncs "
-				"device read-only DMA memory for cpu "
-				"[device address=0x%016llx] [size=%llu bytes] "
-				"[mapped with %s] [synced with %s]\n",
-				(unsigned long long)addr, entry->size,
-				dir2name[entry->direction],
-				dir2name[direction]);
+			   "device read-only DMA memory for cpu "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [synced with %s]\n",
+			   (unsigned long long)addr,
+			   (unsigned long long)entry->size,
+			   dir2name[entry->direction],
+			   dir2name[direction]);
 
 	if (!to_cpu && !(entry->direction = DMA_TO_DEVICE) &&
 		       !(direction = DMA_FROM_DEVICE))
 		err_printk(dev, entry, "DMA-API: device driver syncs "
-				"device write-only DMA memory to device "
-				"[device address=0x%016llx] [size=%llu bytes] "
-				"[mapped with %s] [synced with %s]\n",
-				(unsigned long long)addr, entry->size,
-				dir2name[entry->direction],
-				dir2name[direction]);
+			   "device write-only DMA memory to device "
+			   "[device address=0x%016llx] [size=%llu bytes] "
+			   "[mapped with %s] [synced with %s]\n",
+			   (unsigned long long)addr,
+			   (unsigned long long)entry->size,
+			   dir2name[entry->direction],
+			   dir2name[direction]);
 
 out:
 	put_hash_bucket(bucket, &flags);
-- 
1.6.0.6

