From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Date: Mon, 18 Mar 2013 02:45:43 +0000
Subject: [PATCH 1/1] ia64, mm: add WB check for early_ioremap
Message-Id: <1363574743-4839-1-git-send-email-zhen-hual@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lizhenhua@hp.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Li, Zhen-Hua" <zhen-hual@hp.com>

From: "Li, Zhen-Hua" <zhen-hual@hp.com>

On ia64 system , the function early_ioremap returned to uncached memory without checking. This causes efi error and kernel failed in booting.
So I add a check to test whether memory has EFI_MEMORY_WB set.
And the function kern_mem_attribute can be called in early_ function.

See the document Documentation/ia64/aliasing.txt for more details.

Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
---
 arch/ia64/mm/ioremap.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 3dccdd8..43964cd 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -16,7 +16,7 @@
 #include <asm/meminit.h>
 
 static inline void __iomem *
-__ioremap (unsigned long phys_addr)
+__ioremap_uc(unsigned long phys_addr)
 {
 	return (void __iomem *) (__IA64_UNCACHED_OFFSET | phys_addr);
 }
@@ -24,7 +24,11 @@ __ioremap (unsigned long phys_addr)
 void __iomem *
 early_ioremap (unsigned long phys_addr, unsigned long size)
 {
-	return __ioremap(phys_addr);
+	u64 attr;
+	attr = kern_mem_attribute(phys_addr, size);
+	if (attr & EFI_MEMORY_WB)
+		return (void __iomem *) phys_to_virt(phys_addr);
+	return __ioremap_uc(phys_addr);
 }
 
 void __iomem *
@@ -47,7 +51,7 @@ ioremap (unsigned long phys_addr, unsigned long size)
 	if (attr & EFI_MEMORY_WB)
 		return (void __iomem *) phys_to_virt(phys_addr);
 	else if (attr & EFI_MEMORY_UC)
-		return __ioremap(phys_addr);
+		return __ioremap_uc(phys_addr);
 
 	/*
 	 * Some chipsets don't support UC access to memory.  If
@@ -93,7 +97,7 @@ ioremap (unsigned long phys_addr, unsigned long size)
 		return (void __iomem *) (offset + (char __iomem *)addr);
 	}
 
-	return __ioremap(phys_addr);
+	return __ioremap_uc(phys_addr);
 }
 EXPORT_SYMBOL(ioremap);
 
@@ -103,7 +107,7 @@ ioremap_nocache (unsigned long phys_addr, unsigned long size)
 	if (kern_mem_attribute(phys_addr, size) & EFI_MEMORY_WB)
 		return NULL;
 
-	return __ioremap(phys_addr);
+	return __ioremap_uc(phys_addr);
 }
 EXPORT_SYMBOL(ioremap_nocache);
 
-- 
1.7.10.4

