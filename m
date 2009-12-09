From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 09 Dec 2009 01:56:41 +0000
Subject: [PATCH] ia64: preallocate IA64_IRQ_MOVE_VECTOR
Message-Id: <4B1F03D9.7050108@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Previously, we tried to use IA64_DEF_FIRST_DEVICE_VECTOR (0x30) as the
IA64_IRQ_MOVE_VECTOR.  However, we allocate other IRQs from the device
vector range, so there's no guarantee that IA64_DEF_FIRST_DEVICE_VECTOR
will still be available when we register IA64_IRQ_MOVE_VECTOR.
    
This patch statically allocates 0x30 for IA64_IRQ_MOVE_VECTOR and
removes it from the device vector range.
    
Without this patch, we crash on machines like the HP rx3600 that use
vector 48 (0x30) as the ACPI SCI interrupt:
    
    kernel BUG at arch/ia64/kernel/irq_ia64.c:647!
    swapper[0]: bugcheck! 0 [1]
    Modules linked in:

    Pid: 0, CPU 0, comm:              swapper
    psr : 00001010084a2018 ifs : 800000000000030e ip  : [<a000000100012ed0>]    Not tainted (2.6.32-rc8-00184-gd5d4ec8)
    ip is at ia64_native_register_percpu_irq+0x110/0x1e0
    
Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Tested-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Tested-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

---
 arch/ia64/include/asm/hw_irq.h |    6 ++++++
 arch/ia64/kernel/irq_ia64.c    |    6 +-----
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: linux-2.6.32/arch/ia64/include/asm/hw_irq.h
=================================--- linux-2.6.32.orig/arch/ia64/include/asm/hw_irq.h
+++ linux-2.6.32/arch/ia64/include/asm/hw_irq.h
@@ -59,7 +59,13 @@ typedef u16 ia64_vector;
 extern int ia64_first_device_vector;
 extern int ia64_last_device_vector;
 
+#if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined (CONFIG_IA64_DIG))
+/* Reserve the lower priority vector than device vectors for "move IRQ" IPI */
+#define IA64_IRQ_MOVE_VECTOR		0x30	/* "move IRQ" IPI */
+#define IA64_DEF_FIRST_DEVICE_VECTOR	0x31
+#else
 #define IA64_DEF_FIRST_DEVICE_VECTOR	0x30
+#endif
 #define IA64_DEF_LAST_DEVICE_VECTOR	0xe7
 #define IA64_FIRST_DEVICE_VECTOR	ia64_first_device_vector
 #define IA64_LAST_DEVICE_VECTOR		ia64_last_device_vector
Index: linux-2.6.32/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.32.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.32/arch/ia64/kernel/irq_ia64.c
@@ -260,7 +260,6 @@ void __setup_vector_irq(int cpu)
 }
 
 #if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG))
-#define IA64_IRQ_MOVE_VECTOR	IA64_DEF_FIRST_DEVICE_VECTOR
 
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
@@ -659,11 +658,8 @@ init_IRQ (void)
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 #if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
-	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
-		BUG_ON(IA64_FIRST_DEVICE_VECTOR != IA64_IRQ_MOVE_VECTOR);
-		IA64_FIRST_DEVICE_VECTOR++;
+	if (vector_domain_type != VECTOR_DOMAIN_NONE)
 		register_percpu_irq(IA64_IRQ_MOVE_VECTOR, &irq_move_irqaction);
-	}
 #endif
 #endif
 #ifdef CONFIG_PERFMON

