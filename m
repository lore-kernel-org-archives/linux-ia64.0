From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Dec 2005 23:56:11 +0000
Subject: [patch 1/2] /dev/mem __HAVE_PHYS_MEM_ACCESS_PROT tidy-up
Message-Id: <200512131656.11601.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org

Tidy up __HAVE_PHYS_MEM_ACCESS_PROT usage to make mmap_mem() easier to read.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

 drivers/char/mem.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

Index: work5/drivers/char/mem.c
=================================--- work5.orig/drivers/char/mem.c	2005-12-09 15:52:28.000000000 -0700
+++ work5/drivers/char/mem.c	2005-12-09 16:17:50.000000000 -0700
@@ -228,20 +228,25 @@
 	return written;
 }
 
+#ifndef __HAVE_PHYS_MEM_ACCESS_PROT
+static pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
+				     unsigned long size, pgprot_t vma_prot)
+{
+#ifdef pgprot_noncached
+	unsigned long offset = pfn << PAGE_SHIFT;
+
+	if (uncached_access(file, offset))
+		return pgprot_noncached(vma_prot);
+#endif
+	return vma_prot;
+}
+#endif
+
 static int mmap_mem(struct file * file, struct vm_area_struct * vma)
 {
-#if defined(__HAVE_PHYS_MEM_ACCESS_PROT)
 	vma->vm_page_prot = phys_mem_access_prot(file, vma->vm_pgoff,
 						 vma->vm_end - vma->vm_start,
 						 vma->vm_page_prot);
-#elif defined(pgprot_noncached)
-	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
-	int uncached;
-
-	uncached = uncached_access(file, offset);
-	if (uncached)
-		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-#endif
 
 	/* Remap-pfn-range will mark the range VM_IO and VM_RESERVED */
 	if (remap_pfn_range(vma,
