From: Mike Habeck <habeck@sgi.com>
Date: Fri, 25 Mar 2005 19:34:24 +0000
Subject: [PATCH 2.6.12 0/0] Altix only: Fix for sn_dma_flush
Message-Id: <424467C0.5B60B7A0@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------E1D6981551A892136DEA14A3"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------E1D6981551A892136DEA14A3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Tony,

The following patch fixes a bug in the SGI Altix sn_dma_flush code.  
sn_dma_flush is broken in 2.6.  The code isn't waiting for the DMA 
data to be flushed out of the PIC ASIC. This patch is based off the 
linux-ia64-test-2.6.12 tree

Signed-off-by: Mike Habeck <habeck@sgi.com>
--------------E1D6981551A892136DEA14A3
Content-Type: text/plain; charset=us-ascii;
 name="sn_dma_flush.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn_dma_flush.patch"

Index: test-2.6.12/arch/ia64/sn/pci/pcibr/pcibr_dma.c
===================================================================
--- test-2.6.12.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-03-24 14:34:42.591117130 -0600
+++ test-2.6.12/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-03-24 15:56:33.535718144 -0600
@@ -301,7 +301,7 @@
 		spin_lock_irqsave(&((struct sn_flush_device_list *)p)->
 				  sfdl_flush_lock, flags);
 
-		p->sfdl_flush_value = 0;
+		*p->sfdl_flush_addr = 0;
 
 		/* force an interrupt. */
 		*(volatile uint32_t *)(p->sfdl_force_int_addr) = 1;

--------------E1D6981551A892136DEA14A3--

