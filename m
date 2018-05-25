From: Christoph Hellwig <hch@lst.de>
Date: Fri, 25 May 2018 14:35:11 +0000
Subject: [PATCH 6/7] x86: remove the explicit nodac and allowdac option
Message-Id: <20180525143512.1466-7-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de>
In-Reply-To: <20180525143512.1466-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

This is something drivers should decide (modulo chipset quirks like
for VIA), which as far as I can tell is how things have been handled
for the last 15 years.

Note that we keep the usedac option for now, as it is used in the wild
to override the too generic VIA quirk.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/x86/x86_64/boot-options.txt | 5 -----
 arch/x86/kernel/pci-dma.c                 | 4 ++--
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index 341588ec4e29..8d109ef67ab6 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -236,11 +236,6 @@ IOMMU (input/output memory management unit)
     nomerge            Don't do scatter-gather (SG) merging.
     noaperture         Ask the IOMMU not to touch the aperture for AGP.
     noagp              Don't initialize the AGP driver and use full aperture.
-    allowdac           Allow double-address cycle (DAC) mode, i.e. DMA >4GB.
-                       DAC is used with 32-bit PCI to push a 64-bit address in
-                       two cycles. When off all DMA over >4GB is forced through
-                       an IOMMU or software bounce buffering.
-    nodac              Forbid DAC mode, i.e. DMA >4GB.
     panic              Always panic when IOMMU overflows.
     calgary            Use the Calgary IOMMU if it is available
 
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 91dff954b745..b5cbef974bd1 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -125,9 +125,9 @@ static __init int iommu_setup(char *p)
 		if (!strncmp(p, "forcesac", 8))
 			pr_warn("forcesac option ignored.\n");
 		if (!strncmp(p, "allowdac", 8))
-			forbid_dac = 0;
+			pr_warn("allowdac option ignored.\n");
 		if (!strncmp(p, "nodac", 5))
-			forbid_dac = 1;
+			pr_warn("nodac option ignored.\n");
 		if (!strncmp(p, "usedac", 6)) {
 			forbid_dac = -1;
 			return 1;
-- 
2.17.0

