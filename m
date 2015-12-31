From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:06:05 +0000
Subject: [PATCH v2 03/32] ia64: rename nop->iosapic_nop
Message-Id: <1451572003-2440-4-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiang Liu <jiang.liu@linux.intel.c>

asm-generic/barrier.h defines a nop() macro.
To be able to use this header on ia64, we shouldn't
call local functions/variables nop().

There's one instance where this breaks on ia64:
rename the function to iosapic_nop to avoid the conflict.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/iosapic.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index d2fae05..90fde5b 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -256,7 +256,7 @@ set_rte (unsigned int gsi, unsigned int irq, unsigned int dest, int mask)
 }
 
 static void
-nop (struct irq_data *data)
+iosapic_nop (struct irq_data *data)
 {
 	/* do nothing... */
 }
@@ -415,7 +415,7 @@ iosapic_unmask_level_irq (struct irq_data *data)
 #define iosapic_shutdown_level_irq	mask_irq
 #define iosapic_enable_level_irq	unmask_irq
 #define iosapic_disable_level_irq	mask_irq
-#define iosapic_ack_level_irq		nop
+#define iosapic_ack_level_irq		iosapic_nop
 
 static struct irq_chip irq_type_iosapic_level = {
 	.name =			"IO-SAPIC-level",
@@ -453,7 +453,7 @@ iosapic_ack_edge_irq (struct irq_data *data)
 }
 
 #define iosapic_enable_edge_irq		unmask_irq
-#define iosapic_disable_edge_irq	nop
+#define iosapic_disable_edge_irq	iosapic_nop
 
 static struct irq_chip irq_type_iosapic_edge = {
 	.name =			"IO-SAPIC-edge",
-- 
MST

