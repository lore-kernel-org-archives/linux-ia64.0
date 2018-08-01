From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 16:02:44 +0000
Subject: [PATCH 1/9] ia64: remove the kern_mem_attribute export
Message-Id: <20180801160252.25629-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180801160252.25629-1-hch@lst.de>
In-Reply-To: <20180801160252.25629-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

No actually used anywhere.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/efi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 9c09bf390cce..f77d80edddfe 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -842,7 +842,6 @@ kern_mem_attribute (unsigned long phys_addr, unsigned long size)
 	} while (md);
 	return 0;	/* never reached */
 }
-EXPORT_SYMBOL(kern_mem_attribute);
 
 int
 valid_phys_addr_range (phys_addr_t phys_addr, unsigned long size)
-- 
2.18.0

