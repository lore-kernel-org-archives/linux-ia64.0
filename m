From: Fenghua Yu <fenghua.yu@intel.com>
Date: Sat, 09 Dec 2006 00:16:24 +0000
Subject: [PATCH 4/5] Itanium MC Error Injection Tool: Makefile changes
Message-Id: <20061208161624.A1104@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch has Makefile changes.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

--- a/arch/ia64/kernel/Makefile	2006-12-05 18:10:23.000000000 -0800
+++ b/arch/ia64/kernel/Makefile	2006-12-05 18:10:55.000000000 -0800
@@ -32,6 +32,7 @@ obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+ obj-$(CONFIG_AUDIT)		+= audit.o
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
+obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
 
 obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
