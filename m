From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 17:46:20 +0000
Subject: [Linux-ia64] [PATCH] a fix for iosapic.c
Message-Id: <marc-linux-ia64-105590701905888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

If an interrupt source override record of ACPI MADT describes an
override that goes to non-first IO SAPIC, programming
of its IOSAPIC routing table is not done correctly and
eventually you cannot get interrupts correctly.
This patch fixes the problem.

Most platforms (at least BigSur, Lion, Tiger, NEC AzusA) are not
affected by this problem.  Only those who defines such
an interrupt source override record will be affected.

--- david-020722/arch/ia64/kernel/iosapic.c	Tue Jul 23 16:01:24 2002
+++ david-020722-pcihp/arch/ia64/kernel/iosapic.c	Tue Jul 30 20:57:47 2002
@@ -548,18 +548,33 @@
  * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
  */
 void
-iosapic_register_legacy_irq (unsigned long irq,
-			     unsigned long pin, unsigned long polarity,
+iosapic_register_legacy_irq (u32 isa_irq,
+			     u32 global_vector,
+			     unsigned long polarity,
 			     unsigned long edge_triggered)
 {
-	int vector = isa_irq_to_vector(irq);
+	int index, pin, vector;
+	u32 base_irq;
+	char *addr;
 
-	register_irq(irq, vector, (int)pin, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
-		     0, NULL);		/* ignored for override */
+	index = find_iosapic(global_vector);
+
+	if (index < 0) {
+		printk("%s: No corresponding IOSAPIC found : isa irq (%u) -> global vector (%u)\n", __FUNCTION__, isa_irq, global_vector);
+		return;
+	}
+
+	vector = isa_irq_to_vector(isa_irq);
+	addr = iosapic_lists[index].addr;
+	base_irq = iosapic_lists[index].base_irq;
+	pin = global_vector - base_irq; 
+
+	register_irq(global_vector, vector, pin, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
+		     base_irq, addr);
 
 #ifdef DEBUG_IRQ_ROUTING
 	printk("ISA: IRQ %u -> IOSAPIC irq 0x%02x (%s, %s) -> vector %02x\n",
-	       (unsigned) irq, (unsigned) pin,
+	       isa_irq, global_vector,
 	       polarity ? "high" : "low", edge_triggered ? "edge" : "level",
 	       vector);
 #endif
--- david-020722/include/asm-ia64/iosapic.h	Fri Nov  9 14:26:17 2001
+++ david-020722-pcihp/include/asm-ia64/iosapic.h	Tue Jul 30 20:17:03 2002
@@ -56,7 +56,7 @@
 extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
                                  unsigned long edge_triggered, u32 base_irq,
                                  char *iosapic_address);
-extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long pin,
+extern void iosapic_register_legacy_irq (u32 irq, u32 global_vector,
 					 unsigned long polarity, unsigned long trigger);
 extern int iosapic_register_platform_irq (u32 int_type, u32 global_vector, u32 iosapic_vector,
 					  u16 eid, u16 id, unsigned long polarity,



Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


