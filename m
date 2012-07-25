From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 25 Jul 2012 07:15:13 +0000
Subject: [PATCH] ia64: rename platform_name to ia64_platform_name
Message-Id: <20120725071513.GA11381@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The macro name is too generic and conflicts with
snd_soc_dai_link.platform_name, which triggers lots of build errors.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/ia64/include/asm/machvec.h               |    2 +-
 arch/ia64/include/asm/machvec_dig.h           |    2 +-
 arch/ia64/include/asm/machvec_dig_vtd.h       |    2 +-
 arch/ia64/include/asm/machvec_hpsim.h         |    2 +-
 arch/ia64/include/asm/machvec_hpzx1.h         |    2 +-
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h |    2 +-
 arch/ia64/include/asm/machvec_sn2.h           |    2 +-
 arch/ia64/include/asm/machvec_uv.h            |    2 +-
 arch/ia64/include/asm/machvec_xen.h           |    2 +-
 arch/ia64/include/asm/processor.h             |    2 +-
 arch/ia64/pci/fixup.c                         |    4 ++--
 11 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 367d299..2d1ad4b1 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -120,7 +120,7 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 # ifdef MACHVEC_PLATFORM_HEADER
 #  include MACHVEC_PLATFORM_HEADER
 # else
-#  define platform_name		ia64_mv.name
+#  define ia64_platform_name	ia64_mv.name
 #  define platform_setup	ia64_mv.setup
 #  define platform_cpu_init	ia64_mv.cpu_init
 #  define platform_irq_init	ia64_mv.irq_init
diff --git a/arch/ia64/include/asm/machvec_dig.h b/arch/ia64/include/asm/machvec_dig.h
index 8a0752f..1f7403a 100644
--- a/arch/ia64/include/asm/machvec_dig.h
+++ b/arch/ia64/include/asm/machvec_dig.h
@@ -10,7 +10,7 @@ extern ia64_mv_setup_t dig_setup;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name		"dig"
+#define ia64_platform_name	"dig"
 #define platform_setup		dig_setup
 
 #endif /* _ASM_IA64_MACHVEC_DIG_h */
diff --git a/arch/ia64/include/asm/machvec_dig_vtd.h b/arch/ia64/include/asm/machvec_dig_vtd.h
index 6ab1de5..44308b4 100644
--- a/arch/ia64/include/asm/machvec_dig_vtd.h
+++ b/arch/ia64/include/asm/machvec_dig_vtd.h
@@ -11,7 +11,7 @@ extern ia64_mv_dma_init			pci_iommu_alloc;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name				"dig_vtd"
+#define ia64_platform_name			"dig_vtd"
 #define platform_setup				dig_setup
 #define platform_dma_init			pci_iommu_alloc
 
diff --git a/arch/ia64/include/asm/machvec_hpsim.h b/arch/ia64/include/asm/machvec_hpsim.h
index cf72fc8..e757112 100644
--- a/arch/ia64/include/asm/machvec_hpsim.h
+++ b/arch/ia64/include/asm/machvec_hpsim.h
@@ -11,7 +11,7 @@ extern ia64_mv_irq_init_t hpsim_irq_init;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name		"hpsim"
+#define ia64_platform_name	"hpsim"
 #define platform_setup		hpsim_setup
 #define platform_irq_init	hpsim_irq_init
 
diff --git a/arch/ia64/include/asm/machvec_hpzx1.h b/arch/ia64/include/asm/machvec_hpzx1.h
index 3bd83d7..c74d315 100644
--- a/arch/ia64/include/asm/machvec_hpzx1.h
+++ b/arch/ia64/include/asm/machvec_hpzx1.h
@@ -11,7 +11,7 @@ extern ia64_mv_dma_init			sba_dma_init;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name				"hpzx1"
+#define ia64_platform_name			"hpzx1"
 #define platform_setup				dig_setup
 #define platform_dma_init			sba_dma_init
 
diff --git a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
index 1091ac3..906ef62 100644
--- a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
+++ b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
@@ -11,7 +11,7 @@ extern ia64_mv_dma_get_ops			hwsw_dma_get_ops;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name				"hpzx1_swiotlb"
+#define ia64_platform_name			"hpzx1_swiotlb"
 #define platform_setup				dig_setup
 #define platform_dma_init			machvec_noop
 #define platform_dma_get_ops			hwsw_dma_get_ops
diff --git a/arch/ia64/include/asm/machvec_sn2.h b/arch/ia64/include/asm/machvec_sn2.h
index f061a30..ece9fa8 100644
--- a/arch/ia64/include/asm/machvec_sn2.h
+++ b/arch/ia64/include/asm/machvec_sn2.h
@@ -71,7 +71,7 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_fixup_bus;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name			"sn2"
+#define ia64_platform_name		"sn2"
 #define platform_setup			sn_setup
 #define platform_cpu_init		sn_cpu_init
 #define platform_irq_init		sn_irq_init
diff --git a/arch/ia64/include/asm/machvec_uv.h b/arch/ia64/include/asm/machvec_uv.h
index 2931447..2c50853 100644
--- a/arch/ia64/include/asm/machvec_uv.h
+++ b/arch/ia64/include/asm/machvec_uv.h
@@ -20,7 +20,7 @@ extern ia64_mv_setup_t uv_setup;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name			"uv"
+#define ia64_platform_name		"uv"
 #define platform_setup			uv_setup
 
 #endif /* _ASM_IA64_MACHVEC_UV_H */
diff --git a/arch/ia64/include/asm/machvec_xen.h b/arch/ia64/include/asm/machvec_xen.h
index 55f9228..8b8bd0e 100644
--- a/arch/ia64/include/asm/machvec_xen.h
+++ b/arch/ia64/include/asm/machvec_xen.h
@@ -13,7 +13,7 @@ extern ia64_mv_send_ipi_t		xen_platform_send_ipi;
  * platform's machvec structure.  When compiling a non-generic kernel,
  * the macros are used directly.
  */
-#define platform_name				"xen"
+#define ia64_platform_name			"xen"
 #define platform_setup				dig_setup
 #define platform_cpu_init			xen_cpu_init
 #define platform_irq_init			xen_irq_init
diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index 832dd37..944152a 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -719,7 +719,7 @@ enum idle_boot_override {IDLE_NO_OVERRIDE=0, IDLE_HALT, IDLE_FORCE_MWAIT,
 
 void default_idle(void);
 
-#define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
+#define ia64_platform_is(x) (strcmp(x, ia64_platform_name) = 0)
 
 #endif /* !__ASSEMBLY__ */
 
diff --git a/arch/ia64/pci/fixup.c b/arch/ia64/pci/fixup.c
index f5959c0..eab28e3 100644
--- a/arch/ia64/pci/fixup.c
+++ b/arch/ia64/pci/fixup.c
@@ -30,8 +30,8 @@ static void __devinit pci_fixup_video(struct pci_dev *pdev)
 	struct pci_bus *bus;
 	u16 config;
 
-	if ((strcmp(platform_name, "dig") != 0)
-	    && (strcmp(platform_name, "hpzx1")  != 0))
+	if ((strcmp(ia64_platform_name, "dig") != 0)
+	    && (strcmp(ia64_platform_name, "hpzx1")  != 0))
 		return;
 	/* Maybe, this machine supports legacy memory map. */
 
-- 
1.7.10

