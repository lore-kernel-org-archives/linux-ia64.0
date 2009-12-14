From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Dec 2009 20:00:37 +0000
Subject: [PATCH] implement early_io{re,un}map for ia64
Message-Id: <89khjo$e5tirq@orsmga002.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

drivers/pci/dmar.c uses these functions, so provide them for ia64
Date: Mon, 14 Dec 2009 12:00:36 -0800
Message-Id: <4b26996416535305c4@agluck-desktop.sc.intel.com>

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

linux-next hasn't been building for ia64 for a few days. This fixes
the build problem (but hasn't been tested on a system that has a working
iommu).  Need to synchronize so this gets to mainline before Chris'
"intel-iommu: Detect DMAR in hyperspace at probe time" patch.

David: Do you want to run it through your iommu tree, or should
I just pre-emptively push it in via the ia64 tree?

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 0d9d16e..cc8335e 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -424,6 +424,8 @@ __writeq (unsigned long val, volatile void __iomem *addr)
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
 extern void iounmap (volatile void __iomem *addr);
+extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
+extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
 
 /*
  * String version of IO memory access ops:
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 2a14062..3dccdd8 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -22,6 +22,12 @@ __ioremap (unsigned long phys_addr)
 }
 
 void __iomem *
+early_ioremap (unsigned long phys_addr, unsigned long size)
+{
+	return __ioremap(phys_addr);
+}
+
+void __iomem *
 ioremap (unsigned long phys_addr, unsigned long size)
 {
 	void __iomem *addr;
@@ -102,6 +108,11 @@ ioremap_nocache (unsigned long phys_addr, unsigned long size)
 EXPORT_SYMBOL(ioremap_nocache);
 
 void
+early_iounmap (volatile void __iomem *addr, unsigned long size)
+{
+}
+
+void
 iounmap (volatile void __iomem *addr)
 {
 	if (REGION_NUMBER(addr) = RGN_GATE)
