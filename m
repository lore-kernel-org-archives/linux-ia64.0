From: Josh Triplett <josh@joshtriplett.org>
Date: Mon, 19 Nov 2012 05:27:49 +0000
Subject: [PATCH 10/58] swiotlb: Prototype swiotlb_late_init_with_default_size in swiotlb.h
Message-Id: <1353302917-13995-11-git-send-email-josh@joshtriplett.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
In-Reply-To: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Josh Triplett <josh@joshtriplett.org>, David Howells <dhowells@redhat.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alessandro Rubini <rubini@gnudd.com>, Giancarlo Asnaghi <giancarlo.asnaghi@st.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Several source files reference swiotlb_late_init_with_default_size with
an extern prototype; declare it in linux/swiotlb.h instead.

This also ensures that lib/swiotlb.c has a matching prototype for
swiotlb_late_init_with_default_size, keeping the types in sync, and
eliminating warnings from GCC (-Wmissing-prototypes) and Sparse
(-Wdecl).

lib/swiotlb.c:207:1: warning: no previous prototype for ‘swiotlb_late_init_with_default_size’ [-Wmissing-prototypes]

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 arch/ia64/hp/common/sba_iommu.c |    3 +--
 arch/x86/pci/sta2x11-fixup.c    |    2 +-
 include/linux/swiotlb.h         |    1 +
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index bcda5b2..d37d4af 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -38,6 +38,7 @@
 #include <linux/iommu-helper.h>
 #include <linux/dma-mapping.h>
 #include <linux/prefetch.h>
+#include <linux/swiotlb.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
@@ -46,8 +47,6 @@
 
 #include <asm/acpi-ext.h>
 
-extern int swiotlb_late_init_with_default_size (size_t size);
-
 #define PFX "IOC: "
 
 /*
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 9d8a509..27dde02 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -26,9 +26,9 @@
 #include <linux/pci_ids.h>
 #include <linux/export.h>
 #include <linux/list.h>
+#include <linux/swiotlb.h>
 
 #define STA2X11_SWIOTLB_SIZE (4*1024*1024)
-extern int swiotlb_late_init_with_default_size(size_t default_size);
 
 /*
  * We build a list of bus numbers that are under the ConneXt. The
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 8d08b3e..7e3b8c5 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -23,6 +23,7 @@ extern int swiotlb_force;
 #define IO_TLB_SHIFT 11
 
 extern void swiotlb_init(int verbose);
+extern int swiotlb_late_init_with_default_size(size_t default_size);
 extern void swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
 extern unsigned long swiotlb_nr_tbl(void);
 extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
-- 
1.7.10.4

