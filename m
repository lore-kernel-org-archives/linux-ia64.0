From: Alan Mayer <ajm@sgi.com>
Date: Mon, 03 Nov 2003 20:36:29 +0000
Subject: [PATCH] Bug in sn_pci_map_sg causes MCA
Message-Id: <marc-linux-ia64-106789192810902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If sg->dma_address is set, we try to do a __pa() on a dma_address,
then, later, create a dma_addresss from a munged dma_address.  When
this bogus dma_address is used by the card, it results in MCAs.

		--ajm



--- /usr/tmp/TmpDir.5614-0/linux/arch/ia64/sn/io/machvec/pci_dma.c_1.5  Mon Nov  3 14:32:30 2003
+++ linux/arch/ia64/sn/io/machvec/pci_dma.c     Mon Nov  3 13:16:20 2003
@@ -279,8 +279,7 @@
         * scatterlist.
         */
        for (i = 0; i < nents; i++, sg++) {
-               phys_addr = __pa(sg->dma_address ? sg->dma_address :
-                       (unsigned long)page_address(sg->page) + sg->offset);
+               phys_addr = __pa((unsigned long)page_address(sg->page) + sg->offset);
 
                /*
                 * Handle the most common case: 64 bit cards.  This


