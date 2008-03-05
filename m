From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 05 Mar 2008 22:40:32 +0000
Subject: [PATCH] ia64: remove CONFIG_SMP ifdef in ia64_send_ipi()
Message-Id: <200803051540.33114.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When !CONFIG_SMP, cpu_physical_id() is ia64_get_lid(), which is
functionally identical to

    (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff

so there's no need for two versions of this code.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work2/arch/ia64/kernel/irq_ia64.c
=================================--- work2.orig/arch/ia64/kernel/irq_ia64.c	2008-03-05 14:58:02.000000000 -0700
+++ work2/arch/ia64/kernel/irq_ia64.c	2008-03-05 15:05:25.000000000 -0700
@@ -666,11 +666,7 @@
 	unsigned long ipi_data;
 	unsigned long phys_cpu_id;
 
-#ifdef CONFIG_SMP
 	phys_cpu_id = cpu_physical_id(cpu);
-#else
-	phys_cpu_id = (ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff;
-#endif
 
 	/*
 	 * cpu number is in 8bit ID and 8bit EID
