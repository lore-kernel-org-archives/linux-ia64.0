From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 06 Mar 2003 00:20:57 +0000
Subject: [Linux-ia64] ACPI fix for no PCI
Message-Id: <marc-linux-ia64-105590709805982@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andy Grover told me this should be posted here.  It allows ACPI to
compile even with PCI turned off.  Patch against 2.5.60.

Thanks,
Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/kernel/acpi.c work-sn2/arch/ia64/kernel/acpi.c
--- linux-2.5.60-ia64-sn/arch/ia64/kernel/acpi.c	Mon Feb 24 12:27:12 2003
+++ work-sn2/arch/ia64/kernel/acpi.c	Sat Mar  1 12:38:05 2003
@@ -825,6 +825,7 @@
 /* --------------------------------------------------------------------------
                              PCI Interrupt Routing
    -------------------------------------------------------------------------- */
+#ifdef CONFIG_PCI
 
 int __init
 acpi_get_prt (struct pci_vector_struct **vectors, int *count)
@@ -866,7 +867,7 @@
 	*count = acpi_prt.count;
 	return 0;
 }
-
+#endif
 /* Assume IA64 always use I/O SAPIC */
 
 int __init

