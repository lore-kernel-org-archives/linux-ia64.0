From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 20 Feb 2003 18:01:44 +0000
Subject: [Linux-ia64] [PATCH] 3/5 iosapic: simplify ISA IRQ init
Message-Id: <marc-linux-ia64-105590709805889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simplify ISA IRQ init by taking advantage of iosapic_override_isa_irq(),
which already does what we need.

diff -u -ur iosapic-3/arch/ia64/kernel/iosapic.c iosapic-4/arch/ia64/kernel/iosapic.c
--- iosapic-3/arch/ia64/kernel/iosapic.c	2003-02-18 15:24:23.000000000 -0700
+++ iosapic-4/arch/ia64/kernel/iosapic.c	2003-02-18 15:26:54.000000000 -0700
@@ -611,7 +611,7 @@
 void __devinit
 iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
 {
-	int num_rte, vector;
+	int num_rte;
 	unsigned int isa_irq, ver;
 	char *addr;
 
@@ -634,26 +634,15 @@
 	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, gsi_base, gsi_base + num_rte - 1);
 
 	if ((gsi_base = 0) && pcat_compat) {
-		unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
 
 		/*
 		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
 		 * get reprogrammed later on with data from the ACPI Interrupt Source
 		 * Override table.
 		 */
-		for (isa_irq = 0; isa_irq < 16; ++isa_irq) {
-			vector = isa_irq_to_vector(isa_irq);
-
-			register_intr(isa_irq, vector, IOSAPIC_LOWEST_PRIORITY,
-				     /* IOSAPIC_POL_HIGH, IOSAPIC_EDGE */
-				     1, 1);
-
-			DBG("ISA: IRQ %u -> GSI 0x%x (high,edge) -> CPU 0x%04x vector %d\n",
-			    isa_irq, isa_irq, dest, vector);
-
-			/* program the IOSAPIC routing table: */
-			set_rte(vector, dest);
-		}
+		for (isa_irq = 0; isa_irq < 16; ++isa_irq)
+			/* IOSAPIC_POL_HIGH, IOSAPIC_EDGE */
+			iosapic_override_isa_irq(isa_irq, isa_irq, 1, 1);
 	}
 }
 


