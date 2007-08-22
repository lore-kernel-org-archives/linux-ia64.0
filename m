From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 10:53:30 +0000
Subject: [PATCH 2/2] Clear pending interrupts at CPU boot up time
Message-Id: <1187780010.3798.73.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The pending interrupts can be remaining at boot up time on some
platform. This will cause spurious interrupts when interrupt is
enabled for the first time. This patch clears IVR at the CPU
initialization to eliminate such spurious interrupts.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/setup.c |    5 +++++
 1 files changed, 5 insertions(+)

Index: linux-2.6.23-rc3/arch/ia64/kernel/setup.c
=================================--- linux-2.6.23-rc3.orig/arch/ia64/kernel/setup.c
+++ linux-2.6.23-rc3/arch/ia64/kernel/setup.c
@@ -953,6 +953,11 @@ cpu_init (void)
 
 	/* clear TPR & XTP to enable all interrupt classes: */
 	ia64_setreg(_IA64_REG_CR_TPR, 0);
+
+	/* Clear any pending interrupts left by SAL/EFI */
+	while (ia64_get_ivr() != IA64_SPURIOUS_INT_VECTOR)
+		ia64_eoi();
+
 #ifdef CONFIG_SMP
 	normal_xtp();
 #endif


