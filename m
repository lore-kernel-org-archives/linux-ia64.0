From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 07 Oct 2003 20:42:08 +0000
Subject: [PATCH] fix sn2 pci discovery in generic kernels
Message-Id: <marc-linux-ia64-106555967613003@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don't try to use the sn2 I/O code if we're not on sn2 or we may get into
trouble.  Only makes a difference for generic kernels.

Thanks,
Jesse

=== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.10 vs edited ==--- 1.10/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 05:12:36 2003
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Tue Oct  7 11:39:30 2003
@@ -863,6 +863,9 @@
 	int i = 0;
 	struct pci_controller *controller;
 
+	if (!ia64_platform_is("sn2"))
+	    return 0;
+
 	/*
 	 * set pci_raw_ops, etc.
 	 */
