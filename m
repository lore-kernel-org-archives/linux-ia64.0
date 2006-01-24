From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 24 Jan 2006 16:58:32 +0000
Subject: [PATCH] sn_dma_alloc_coherent should use gfp flags
Message-Id: <20060124165832.GA19461@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Takashi helped us track down a bad page state bug we thought was coming
from alsa.  It turns out we weren't paying attention to the gfp flags
that were passed in to sn_dma_alloc_coherent().

From: Takashi Iwai <tiwai@suse.de>
Signed-off-by: Greg Edwards <edwardsg@sgi.com>
Signed-off-by: Mark Maule <maule@sgi.com>
Signed-off-by: Jes Sorensen <jes@sgi.com>

---

 arch/ia64/sn/pci/pci_dma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: git-linus/arch/ia64/sn/pci/pci_dma.c
=================================--- git-linus.orig/arch/ia64/sn/pci/pci_dma.c	2006-01-09 12:52:26.212773620 -0600
+++ git-linus/arch/ia64/sn/pci/pci_dma.c	2006-01-24 10:47:49.532645570 -0600
@@ -90,14 +90,14 @@ void *sn_dma_alloc_coherent(struct devic
 	 */
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
-		struct page *p = alloc_pages_node(node, GFP_ATOMIC, get_order(size));
+		struct page *p = alloc_pages_node(node, flags, get_order(size));
 
 		if (likely(p))
 			cpuaddr = page_address(p);
 		else
 			return NULL;
 	} else
-		cpuaddr = (void *)__get_free_pages(GFP_ATOMIC, get_order(size));
+		cpuaddr = (void *)__get_free_pages(flags, get_order(size));
 
 	if (unlikely(!cpuaddr))
 		return NULL;
