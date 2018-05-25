From: Christoph Hellwig <hch@lst.de>
Date: Fri, 25 May 2018 14:35:09 +0000
Subject: [PATCH 4/7] x86: remove a stray reference to pci-nommu.c
Message-Id: <20180525143512.1466-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de>
In-Reply-To: <20180525143512.1466-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

This is just the minimal workaround.  The file file is mostly either stale
and/or duplicative of Documentation/admin-guide/kernel-parameters.txt,
but that is much more work than I'm willing to do right now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/x86/x86_64/boot-options.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index b297c48389b9..153b3a57fba2 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -187,9 +187,9 @@ PCI
 
 IOMMU (input/output memory management unit)
 
- Currently four x86-64 PCI-DMA mapping implementations exist:
+ Multiple x86-64 PCI-DMA mapping implementations exist, for example:
 
-   1. <arch/x86_64/kernel/pci-nommu.c>: use no hardware/software IOMMU at all
+   1. <lib/dma-direct.c>: use no hardware/software IOMMU at all
       (e.g. because you have < 3 GB memory).
       Kernel boot message: "PCI-DMA: Disabling IOMMU"
 
-- 
2.17.0

