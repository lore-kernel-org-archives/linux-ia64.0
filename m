From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 01 Jun 2005 05:34:04 +0000
Subject: Cleanup some compile warnings
Message-Id: <17053.18636.645884.829572@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi, 
	The attached patch cleans up a compilation warning when ACPI
is turned off (i.e., when compiling for the Ski simulator).

Index: linux-2.6-import/arch/ia64/kernel/mca.c
=================================--- linux-2.6-import.orig/arch/ia64/kernel/mca.c	2005-06-01 15:29:26.829545519 +1000
+++ linux-2.6-import/arch/ia64/kernel/mca.c	2005-06-01 15:30:48.022285413 +1000
@@ -1103,8 +1103,6 @@
 	return IRQ_HANDLED;
 }
 
-#endif /* CONFIG_ACPI */
-
 /*
  *  ia64_mca_cpe_poll
  *
@@ -1122,6 +1120,8 @@
 	platform_send_ipi(first_cpu(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
+#endif /* CONFIG_ACPI */
+
 /*
  * C portion of the OS INIT handler
  *
