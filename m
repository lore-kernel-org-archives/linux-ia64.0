From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 21 Mar 2007 22:21:49 +0000
Subject: [patch 3/5] ia64: allow WB /sys/.../legacy_mem mmaps
Message-Id: <200703211621.49988.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Allow cacheable mmaps of legacy_mem if WB access is supported for the region.
The "legacy_mem" file often contains a shadow option ROM, and some versions of
X depend on this.

Tim Yamin <plasm@roo.me.uk> reported that this change fixes X on a Dell
PowerEdge 3250.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm10/arch/ia64/pci/pci.c
=================================--- work-mm10.orig/arch/ia64/pci/pci.c	2007-03-21 14:13:22.000000000 -0700
+++ work-mm10/arch/ia64/pci/pci.c	2007-03-21 14:15:01.000000000 -0700
@@ -656,8 +656,6 @@
 		return -EINVAL;
 	prot = phys_mem_access_prot(NULL, vma->vm_pgoff, size,
 				    vma->vm_page_prot);
-	if (pgprot_val(prot) != pgprot_val(pgprot_noncached(vma->vm_page_prot)))
-		return -EINVAL;
 
 	addr = pci_get_legacy_mem(bus);
 	if (IS_ERR(addr))
