From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Fri, 09 Oct 2009 08:29:20 +0000
Subject: [PATCH 7/8] ia64: Use bitmap_find_next_zero_area
Message-Id: <1255076961-21325-7-git-send-email-akinobu.mita@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <>
 <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
 <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
 <1255076961-21325-3-git-send-email-akinobu.mita@gmail.com>
 <1255076961-21325-4-git-send-email-akinobu.mita@gmail.com>
 <1255076961-21325-5-git-send-email-akinobu.mita@gmail.com>
 <1255076961-21325-6-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1255076961-21325-6-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-altix@sgi.com

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-altix@sgi.com
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 arch/ia64/sn/pci/tioca_provider.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index 35b2a27..efb4545 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/bitmap.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/io.h>
@@ -369,7 +370,7 @@ tioca_dma_d48(struct pci_dev *pdev, u64 paddr)
 static dma_addr_t
 tioca_dma_mapped(struct pci_dev *pdev, unsigned long paddr, size_t req_size)
 {
-	int i, ps, ps_shift, entry, entries, mapsize, last_entry;
+	int ps, ps_shift, entry, entries, mapsize;
 	u64 xio_addr, end_xio_addr;
 	struct tioca_common *tioca_common;
 	struct tioca_kernel *tioca_kern;
@@ -410,23 +411,13 @@ tioca_dma_mapped(struct pci_dev *pdev, unsigned long paddr, size_t req_size)
 	map = tioca_kern->ca_pcigart_pagemap;
 	mapsize = tioca_kern->ca_pcigart_entries;
 
-	entry = find_first_zero_bit(map, mapsize);
-	while (entry < mapsize) {
-		last_entry = find_next_bit(map, mapsize, entry);
-
-		if (last_entry - entry >= entries)
-			break;
-
-		entry = find_next_zero_bit(map, mapsize, last_entry);
-	}
-
-	if (entry > mapsize) {
+	entry = bitmap_find_next_zero_area(map, mapsize, 0, entries, 0);
+	if (entry >= mapsize) {
 		kfree(ca_dmamap);
 		goto map_return;
 	}
 
-	for (i = 0; i < entries; i++)
-		set_bit(entry + i, map);
+	bitmap_set(map, entry, entries);
 
 	bus_addr = tioca_kern->ca_pciap_base + (entry * ps);
 
-- 
1.5.4.3

