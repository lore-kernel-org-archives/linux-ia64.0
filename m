From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 09 Nov 2007 01:51:01 +0000
Subject: [PATCH] ia64: Fix iosapic interrupt delivery mode for CPE
Message-Id: <4733BD05.8040804@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If "CPEI Processor Override" bit is not set in "Platform Interrupt
Source Flags" in "Platform Interrupt Sources Structure" in ACPI MADT,
the target processor of CPEI is restricted to a specific CPU. Because
of this, the delivery mode for CPEI should be IOSAPIC_FIXED.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.24-rc2/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.24-rc2.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.24-rc2/arch/ia64/kernel/iosapic.c
@@ -938,7 +938,7 @@ iosapic_register_platform_intr (u32 int_
 	      case ACPI_INTERRUPT_CPEI:
 		irq = vector = IA64_CPE_VECTOR;
 		BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
-		delivery = IOSAPIC_LOWEST_PRIORITY;
+		delivery = IOSAPIC_FIXED;
 		mask = 1;
 		break;
 	      default:

