From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 20:22:19 +0000
Subject: [PATCH] Fix PCI root bridge resources to handle prior allocations
Message-Id: <marc-linux-ia64-107177896324094@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Fix PCI root bridge resources to handle prior allocations.

(alloc_resources):  Use insert_resource(), not request_resource(), to
	allocate PCI root bridge windows.  This fixes the problem
	where root bridge window allocation fails because an early
	driver (like VGA) has already allocated things.

=== arch/ia64/pci/pci.c 1.37 vs edited ==--- 1.37/arch/ia64/pci/pci.c	Thu Jul 31 17:47:19 2003
+++ edited/arch/ia64/pci/pci.c	Thu Nov 20 10:45:52 2003
@@ -153,7 +153,7 @@
 	res->end = end;
 	res->flags = flags;
 
-	if (request_resource(root, res))
+	if (insert_resource(root, res))
 		return -EBUSY;
 
 	return 0;

