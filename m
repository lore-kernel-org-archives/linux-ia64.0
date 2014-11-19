From: Paolo Bonzini <pbonzini@redhat.com>
Date: Wed, 19 Nov 2014 21:05:43 +0000
Subject: [PATCH] KVM: ia64: remove
Message-Id: <1416431143-31843-1-git-send-email-pbonzini@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

KVM for ia64 has been marked as broken not just once, but twice even,
and the last patch from the maintainer is now roughly 5 years old.
Time for it to rest in piece.

Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
---
	The patch was edited to keep its size decent, by dropping
	all the removed lines from the deleted files.

 MAINTAINERS                         |    9 -
 arch/ia64/Kconfig                   |    3 -
 arch/ia64/Makefile                  |    1 -
 arch/ia64/include/asm/kvm_host.h    |  609 ----------
 arch/ia64/include/asm/pvclock-abi.h |   48 -
 arch/ia64/include/uapi/asm/kvm.h    |  268 -----
 arch/ia64/kvm/Kconfig               |   66 --
 arch/ia64/kvm/Makefile              |   67 --
 arch/ia64/kvm/asm-offsets.c         |  241 ----
 arch/ia64/kvm/irq.h                 |   33 -
 arch/ia64/kvm/kvm-ia64.c            | 1942 ------------------------------
 arch/ia64/kvm/kvm_fw.c              |  674 -----------
 arch/ia64/kvm/kvm_lib.c             |   21 -
 arch/ia64/kvm/kvm_minstate.h        |  266 -----
 arch/ia64/kvm/lapic.h               |   30 -
 arch/ia64/kvm/memcpy.S              |    1 -
 arch/ia64/kvm/memset.S              |    1 -
 arch/ia64/kvm/misc.h                |   94 --
 arch/ia64/kvm/mmio.c                |  336 ------
 arch/ia64/kvm/optvfault.S           | 1090 -----------------
 arch/ia64/kvm/process.c             | 1024 ----------------
 arch/ia64/kvm/trampoline.S          | 1038 ----------------
 arch/ia64/kvm/vcpu.c                | 2209 -----------------------------------
 arch/ia64/kvm/vcpu.h                |  752 ------------
 arch/ia64/kvm/vmm.c                 |   99 --
 arch/ia64/kvm/vmm_ivt.S             | 1392 ----------------------
 arch/ia64/kvm/vti.h                 |  290 -----
 arch/ia64/kvm/vtlb.c                |  640 ----------
 virt/kvm/ioapic.c                   |  5 -
 virt/kvm/ioapic.h                   |  1 -
 virt/kvm/irq_comm.c                 | 22 -
 31 files changed, 13272 deletions(-)
 delete mode 100644 arch/ia64/include/asm/kvm_host.h
 delete mode 100644 arch/ia64/include/asm/pvclock-abi.h
 delete mode 100644 arch/ia64/include/uapi/asm/kvm.h
 delete mode 100644 arch/ia64/kvm/Kconfig
 delete mode 100644 arch/ia64/kvm/Makefile
 delete mode 100644 arch/ia64/kvm/asm-offsets.c
 delete mode 100644 arch/ia64/kvm/irq.h
 delete mode 100644 arch/ia64/kvm/kvm-ia64.c
 delete mode 100644 arch/ia64/kvm/kvm_fw.c
 delete mode 100644 arch/ia64/kvm/kvm_lib.c
 delete mode 100644 arch/ia64/kvm/kvm_minstate.h
 delete mode 100644 arch/ia64/kvm/lapic.h
 delete mode 100644 arch/ia64/kvm/memcpy.S
 delete mode 100644 arch/ia64/kvm/memset.S
 delete mode 100644 arch/ia64/kvm/misc.h
 delete mode 100644 arch/ia64/kvm/mmio.c
 delete mode 100644 arch/ia64/kvm/optvfault.S
 delete mode 100644 arch/ia64/kvm/process.c
 delete mode 100644 arch/ia64/kvm/trampoline.S
 delete mode 100644 arch/ia64/kvm/vcpu.c
 delete mode 100644 arch/ia64/kvm/vcpu.h
 delete mode 100644 arch/ia64/kvm/vmm.c
 delete mode 100644 arch/ia64/kvm/vmm_ivt.S
 delete mode 100644 arch/ia64/kvm/vti.h
 delete mode 100644 arch/ia64/kvm/vtlb.c

diff --git a/MAINTAINERS b/MAINTAINERS
index a12edf2624e5..56705138ca74 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5244,15 +5244,6 @@ S:       Supported
 F:     arch/powerpc/include/asm/kvm*
 F:     arch/powerpc/kvm/

-KERNEL VIRTUAL MACHINE For Itanium (KVM/IA64)
-M:     Xiantao Zhang <xiantao.zhang@intel.com>
-L:     kvm-ia64@vger.kernel.org
-W:     http://kvm.qumranet.com
-S:     Supported
-F:     Documentation/ia64/kvm.txt
-F:     arch/ia64/include/asm/kvm*
-F:     arch/ia64/kvm/
-
 KERNEL VIRTUAL MACHINE for s390 (KVM/s390)
 M:     Christian Borntraeger <borntraeger@de.ibm.com>
 M:     Cornelia Huck <cornelia.huck@de.ibm.com>
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index c84c88bbbbd7..11afe7ab1981 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -21,7 +21,6 @@ config IA64
 	select HAVE_DYNAMIC_FTRACE if (!ITANIUM)
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
-	select HAVE_KVM
 	select TTY
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_DMA_API_DEBUG
@@ -640,8 +639,6 @@ source "security/Kconfig"
 
 source "crypto/Kconfig"
 
-source "arch/ia64/kvm/Kconfig"
-
 source "lib/Kconfig"
 
 config IOMMU_HELPER
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 5441b14994fc..970d0bd99621 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -53,7 +53,6 @@ core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
 core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
-core-$(CONFIG_KVM) 		+= arch/ia64/kvm/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
diff --git a/arch/ia64/include/asm/kvm_host.h b/arch/ia64/include/asm/kvm_host.h
deleted file mode 100644
index 4729752b7256..000000000000
--- a/arch/ia64/include/asm/kvm_host.h
+++ /dev/null
@@ -1,609 +0,0 @@
diff --git a/arch/ia64/include/asm/pvclock-abi.h b/arch/ia64/include/asm/pvclock-abi.h
deleted file mode 100644
index 42b233bedeb5..000000000000
--- a/arch/ia64/include/asm/pvclock-abi.h
+++ /dev/null
@@ -1,48 +0,0 @@
diff --git a/arch/ia64/include/uapi/asm/kvm.h b/arch/ia64/include/uapi/asm/kvm.h
deleted file mode 100644
index 99503c284400..000000000000
--- a/arch/ia64/include/uapi/asm/kvm.h
+++ /dev/null
@@ -1,268 +0,0 @@
diff --git a/arch/ia64/kvm/Kconfig b/arch/ia64/kvm/Kconfig
deleted file mode 100644
index 3d50ea955c4c..000000000000
--- a/arch/ia64/kvm/Kconfig
+++ /dev/null
@@ -1,66 +0,0 @@
diff --git a/arch/ia64/kvm/Makefile b/arch/ia64/kvm/Makefile
deleted file mode 100644
index 18e45ec49bbf..000000000000
--- a/arch/ia64/kvm/Makefile
+++ /dev/null
@@ -1,67 +0,0 @@
diff --git a/arch/ia64/kvm/asm-offsets.c b/arch/ia64/kvm/asm-offsets.c
deleted file mode 100644
index 9324c875caf5..000000000000
--- a/arch/ia64/kvm/asm-offsets.c
+++ /dev/null
@@ -1,241 +0,0 @@
diff --git a/arch/ia64/kvm/irq.h b/arch/ia64/kvm/irq.h
deleted file mode 100644
index c0785a728271..000000000000
--- a/arch/ia64/kvm/irq.h
+++ /dev/null
@@ -1,33 +0,0 @@
diff --git a/arch/ia64/kvm/kvm-ia64.c b/arch/ia64/kvm/kvm-ia64.c
deleted file mode 100644
index ec6b9acb6bea..000000000000
--- a/arch/ia64/kvm/kvm-ia64.c
+++ /dev/null
@@ -1,1942 +0,0 @@
diff --git a/arch/ia64/kvm/kvm_fw.c b/arch/ia64/kvm/kvm_fw.c
deleted file mode 100644
index cb548ee9fcae..000000000000
--- a/arch/ia64/kvm/kvm_fw.c
+++ /dev/null
@@ -1,674 +0,0 @@
diff --git a/arch/ia64/kvm/kvm_lib.c b/arch/ia64/kvm/kvm_lib.c
deleted file mode 100644
index f1268b8e6f9e..000000000000
--- a/arch/ia64/kvm/kvm_lib.c
+++ /dev/null
@@ -1,21 +0,0 @@
diff --git a/arch/ia64/kvm/kvm_minstate.h b/arch/ia64/kvm/kvm_minstate.h
deleted file mode 100644
index b2bcaa2787aa..000000000000
--- a/arch/ia64/kvm/kvm_minstate.h
+++ /dev/null
@@ -1,266 +0,0 @@
diff --git a/arch/ia64/kvm/lapic.h b/arch/ia64/kvm/lapic.h
deleted file mode 100644
index c5f92a926a9a..000000000000
--- a/arch/ia64/kvm/lapic.h
+++ /dev/null
@@ -1,30 +0,0 @@
diff --git a/arch/ia64/kvm/memcpy.S b/arch/ia64/kvm/memcpy.S
deleted file mode 100644
index c04cdbe9f80f..000000000000
--- a/arch/ia64/kvm/memcpy.S
+++ /dev/null
@@ -1 +0,0 @@
diff --git a/arch/ia64/kvm/memset.S b/arch/ia64/kvm/memset.S
deleted file mode 100644
index 83c3066d844a..000000000000
--- a/arch/ia64/kvm/memset.S
+++ /dev/null
@@ -1 +0,0 @@
diff --git a/arch/ia64/kvm/misc.h b/arch/ia64/kvm/misc.h
deleted file mode 100644
index dd979e00b574..000000000000
--- a/arch/ia64/kvm/misc.h
+++ /dev/null
@@ -1,94 +0,0 @@
diff --git a/arch/ia64/kvm/mmio.c b/arch/ia64/kvm/mmio.c
deleted file mode 100644
index f1e17d3d6cd9..000000000000
--- a/arch/ia64/kvm/mmio.c
+++ /dev/null
@@ -1,336 +0,0 @@
diff --git a/arch/ia64/kvm/optvfault.S b/arch/ia64/kvm/optvfault.S
deleted file mode 100644
index f793be3effff..000000000000
--- a/arch/ia64/kvm/optvfault.S
+++ /dev/null
@@ -1,1090 +0,0 @@
diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
deleted file mode 100644
index b0398740b48d..000000000000
--- a/arch/ia64/kvm/process.c
+++ /dev/null
@@ -1,1024 +0,0 @@
diff --git a/arch/ia64/kvm/trampoline.S b/arch/ia64/kvm/trampoline.S
deleted file mode 100644
index 30897d44d61e..000000000000
--- a/arch/ia64/kvm/trampoline.S
+++ /dev/null
@@ -1,1038 +0,0 @@
diff --git a/arch/ia64/kvm/vcpu.c b/arch/ia64/kvm/vcpu.c
deleted file mode 100644
index 958815c9787d..000000000000
--- a/arch/ia64/kvm/vcpu.c
+++ /dev/null
@@ -1,2209 +0,0 @@
diff --git a/arch/ia64/kvm/vcpu.h b/arch/ia64/kvm/vcpu.h
deleted file mode 100644
index 988911b4cc7a..000000000000
--- a/arch/ia64/kvm/vcpu.h
+++ /dev/null
@@ -1,752 +0,0 @@
diff --git a/arch/ia64/kvm/vmm.c b/arch/ia64/kvm/vmm.c
deleted file mode 100644
index 176a12cd56de..000000000000
--- a/arch/ia64/kvm/vmm.c
+++ /dev/null
@@ -1,99 +0,0 @@
diff --git a/arch/ia64/kvm/vmm_ivt.S b/arch/ia64/kvm/vmm_ivt.S
deleted file mode 100644
index 397e34a63e18..000000000000
--- a/arch/ia64/kvm/vmm_ivt.S
+++ /dev/null
@@ -1,1392 +0,0 @@
diff --git a/arch/ia64/kvm/vti.h b/arch/ia64/kvm/vti.h
deleted file mode 100644
index b214b5b0432d..000000000000
--- a/arch/ia64/kvm/vti.h
+++ /dev/null
@@ -1,290 +0,0 @@
diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
deleted file mode 100644
index a7869f8f49a6..000000000000
--- a/arch/ia64/kvm/vtlb.c
+++ /dev/null
@@ -1,640 +0,0 @@
diff --git a/virt/kvm/ioapic.c b/virt/kvm/ioapic.c
index 381077d8cc5d..1cb8af07bf2b 100644
--- a/virt/kvm/ioapic.c
+++ b/virt/kvm/ioapic.c
@@ -544,11 +544,6 @@ static int ioapic_mmio_write(struct kvm_io_device *this, gpa_t addr, int len,
 	case IOAPIC_REG_WINDOW:
 		ioapic_write_indirect(ioapic, data);
 		break;
-#ifdef	CONFIG_IA64
-	case IOAPIC_REG_EOI:
-		__kvm_ioapic_update_eoi(NULL, ioapic, data, IOAPIC_LEVEL_TRIG);
-		break;
-#endif
 
 	default:
 		break;
diff --git a/virt/kvm/ioapic.h b/virt/kvm/ioapic.h
index 35c0e3ed72bf..e2d34012ac7e 100644
--- a/virt/kvm/ioapic.h
+++ b/virt/kvm/ioapic.h
@@ -19,7 +19,6 @@ struct kvm_vcpu;
 /* Direct registers. */
 #define IOAPIC_REG_SELECT  0x00
 #define IOAPIC_REG_WINDOW  0x10
-#define IOAPIC_REG_EOI     0x40	/* IA64 IOSAPIC only */
 
 /* Indirect registers. */
 #define IOAPIC_REG_APIC_ID 0x00	/* x86 IOAPIC only */
diff --git a/virt/kvm/irq_comm.c b/virt/kvm/irq_comm.c
index 963b8995a9e8..1345bde064f5 100644
--- a/virt/kvm/irq_comm.c
+++ b/virt/kvm/irq_comm.c
@@ -26,9 +26,6 @@
 #include <trace/events/kvm.h>
 
 #include <asm/msidef.h>
-#ifdef CONFIG_IA64
-#include <asm/iosapic.h>
-#endif
 
 #include "irq.h"
 
@@ -57,12 +54,7 @@ static int kvm_set_ioapic_irq(struct kvm_kernel_irq_routing_entry *e,
 
 inline static bool kvm_is_dm_lowest_prio(struct kvm_lapic_irq *irq)
 {
-#ifdef CONFIG_IA64
-	return irq->delivery_mode =
-		(IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
-#else
 	return irq->delivery_mode = APIC_DM_LOWEST;
-#endif
 }
 
 int kvm_irq_delivery_to_apic(struct kvm *kvm, struct kvm_lapic *src,
@@ -346,20 +338,6 @@ static const struct kvm_irq_routing_entry default_routing[] = {
 	ROUTING_ENTRY1(18), ROUTING_ENTRY1(19),
 	ROUTING_ENTRY1(20), ROUTING_ENTRY1(21),
 	ROUTING_ENTRY1(22), ROUTING_ENTRY1(23),
-#ifdef CONFIG_IA64
-	ROUTING_ENTRY1(24), ROUTING_ENTRY1(25),
-	ROUTING_ENTRY1(26), ROUTING_ENTRY1(27),
-	ROUTING_ENTRY1(28), ROUTING_ENTRY1(29),
-	ROUTING_ENTRY1(30), ROUTING_ENTRY1(31),
-	ROUTING_ENTRY1(32), ROUTING_ENTRY1(33),
-	ROUTING_ENTRY1(34), ROUTING_ENTRY1(35),
-	ROUTING_ENTRY1(36), ROUTING_ENTRY1(37),
-	ROUTING_ENTRY1(38), ROUTING_ENTRY1(39),
-	ROUTING_ENTRY1(40), ROUTING_ENTRY1(41),
-	ROUTING_ENTRY1(42), ROUTING_ENTRY1(43),
-	ROUTING_ENTRY1(44), ROUTING_ENTRY1(45),
-	ROUTING_ENTRY1(46), ROUTING_ENTRY1(47),
-#endif
 };
 
 int kvm_setup_default_irq_routing(struct kvm *kvm)
-- 
2.1.0

