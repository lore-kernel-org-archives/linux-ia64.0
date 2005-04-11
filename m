From: Mark Maule <maule@sgi.com>
Date: Mon, 11 Apr 2005 20:19:32 +0000
Subject: [PATCH 2.6.12 1/1] altix: fix TIOCA dmamap list_add
Message-Id: <20050411201932.26788.64806.81672@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Corract a bug where tioca_dma_mapped() is putting tioca dma map structs
on the wrong list.

Signed-off-by: Mark Maule <maule@sgi.com>

=== arch/ia64/sn/pci/tioca_provider.c 1.2 vs edited ==--- 1.2/arch/ia64/sn/pci/tioca_provider.c	2005-03-16 17:22:12 -06:00
+++ edited/arch/ia64/sn/pci/tioca_provider.c	2005-04-11 15:09:37 -05:00
@@ -431,7 +431,7 @@
 	ca_dmamap->cad_dma_addr = bus_addr;
 	ca_dmamap->cad_gart_size = entries;
 	ca_dmamap->cad_gart_entry = entry;
-	list_add(&ca_dmamap->cad_list, &tioca_kern->ca_list);
+	list_add(&ca_dmamap->cad_list, &tioca_kern->ca_dmamaps);
 
 	if (xio_addr % ps) {
 		tioca_kern->ca_pcigart[entry] = tioca_paddr_to_gart(xio_addr);
