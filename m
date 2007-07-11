From: Alex Chiang <achiang@hp.com>
Date: Wed, 11 Jul 2007 17:02:15 +0000
Subject: [PATCH] ia64: prevent MCA when performing MMIO mmap to PCI config space
Message-Id: <20070711170215.GD20904@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Example memory map (HP rx7640 with 'default' acpiconfig setting, VGA disabled):
   0x00000000 - 0x3FFFBFFF  supports only WB (cacheable) access

If a user attempts to perform an MMIO mmap (using the PCIIOC_MMAP_IS_MEM ioctl) 
to PCI config space (like mmap'ing and accessing memory at 0xA0000), 
we will MCA because the kernel will attempt to use a mapping with the UC 
attribute.

So check the memory attribute in kern_mmap and the EFI memmap. If WC is
requested, and WC or UC access is supported for the region, allow it.
Otherwise, use the same attribute the kernel uses.

Updates documentation and test cases as well.

Signed-off-by: Alex Chiang <achiang@hp.com>
Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
---

Index: linux-2.6/Documentation/ia64/aliasing-test.c
=================================--- linux-2.6.orig/Documentation/ia64/aliasing-test.c	2007-07-10 17:59:09.000000000 -0600
+++ linux-2.6/Documentation/ia64/aliasing-test.c	2007-07-10 18:30:38.000000000 -0600
@@ -19,6 +19,7 @@
 #include <sys/mman.h>
 #include <sys/stat.h>
 #include <unistd.h>
+#include <linux/pci.h>
 
 int sum;
 
@@ -34,13 +35,19 @@
 		return -1;
 	}
 
+	if (fnmatch("/proc/bus/pci/*", path, 0) = 0) {
+		rc = ioctl(fd, PCIIOC_MMAP_IS_MEM);
+		if (rc = -1)
+			perror("PCIIOC_MMAP_IS_MEM ioctl");
+	}
+
 	addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, offset);
 	if (addr = MAP_FAILED)
 		return 1;
 
 	if (touch) {
 		c = (int *) addr;
-		while (c < (int *) (offset + length))
+		while (c < (int *) (addr + length))
 			sum += *c++;
 	}
 
@@ -54,7 +61,7 @@
 	return 0;
 }
 
-int scan_sysfs(char *path, char *file, off_t offset, size_t length, int touch)
+int scan_tree(char *path, char *file, off_t offset, size_t length, int touch)
 {
 	struct dirent **namelist;
 	char *name, *path2;
@@ -93,7 +100,7 @@
 		} else {
 			r = lstat(path2, &buf);
 			if (r = 0 && S_ISDIR(buf.st_mode)) {
-				rc = scan_sysfs(path2, file, offset, length, touch);
+				rc = scan_tree(path2, file, offset, length, touch);
 				if (rc < 0)
 					return rc;
 			}
@@ -238,10 +245,15 @@
 	else
 		fprintf(stderr, "FAIL: /dev/mem 0x0-0x100000 not accessible\n");
 
-	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0, 0xA0000, 1);
-	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0xA0000, 0x20000, 0);
-	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0xC0000, 0x40000, 1);
-	scan_sysfs("/sys/class/pci_bus", "legacy_mem", 0, 1024*1024, 0);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 0xA0000, 1);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xA0000, 0x20000, 0);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xC0000, 0x40000, 1);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 1024*1024, 0);
 
 	scan_rom("/sys/devices", "rom");
+
+	scan_tree("/proc/bus/pci", "??.?", 0, 0xA0000, 1);
+	scan_tree("/proc/bus/pci", "??.?", 0xA0000, 0x20000, 0);
+	scan_tree("/proc/bus/pci", "??.?", 0xC0000, 0x40000, 1);
+	scan_tree("/proc/bus/pci", "??.?", 0, 1024*1024, 0);
 }
Index: linux-2.6/arch/ia64/pci/pci.c
=================================--- linux-2.6.orig/arch/ia64/pci/pci.c	2007-07-10 17:59:09.000000000 -0600
+++ linux-2.6/arch/ia64/pci/pci.c	2007-07-10 18:30:38.000000000 -0600
@@ -591,6 +591,9 @@
 pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 		     enum pci_mmap_state mmap_state, int write_combine)
 {
+	unsigned long size = vma->vm_end - vma->vm_start;
+	pgprot_t prot;
+
 	/*
 	 * I/O space cannot be accessed via normal processor loads and
 	 * stores on this platform.
@@ -604,15 +607,24 @@
 		 */
 		return -EINVAL;
 
+	if (!valid_mmap_phys_addr_range(vma->vm_pgoff, size))
+		return -EINVAL;
+
+	prot = phys_mem_access_prot(NULL, vma->vm_pgoff, size,
+				    vma->vm_page_prot);
+
 	/*
-	 * Leave vm_pgoff as-is, the PCI space address is the physical
-	 * address on this platform.
+	 * If the user requested WC, the kernel uses UC or WC for this region,
+	 * and the chipset supports WC, we can use WC. Otherwise, we have to
+	 * use the same attribute the kernel uses.
 	 */
-	if (write_combine && efi_range_is_wc(vma->vm_start,
-					     vma->vm_end - vma->vm_start))
+	if (write_combine &&
+	    ((pgprot_val(prot) & _PAGE_MA_MASK) = _PAGE_MA_UC ||
+	     (pgprot_val(prot) & _PAGE_MA_MASK) = _PAGE_MA_WC) &&
+	    efi_range_is_wc(vma->vm_start, vma->vm_end - vma->vm_start))
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	else
-		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		vma->vm_page_prot = prot;
 
 	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
 			     vma->vm_end - vma->vm_start, vma->vm_page_prot))
Index: linux-2.6/Documentation/ia64/aliasing.txt
=================================--- linux-2.6.orig/Documentation/ia64/aliasing.txt	2007-07-10 17:59:09.000000000 -0600
+++ linux-2.6/Documentation/ia64/aliasing.txt	2007-07-10 18:30:38.000000000 -0600
@@ -112,6 +112,18 @@
 
 	The /dev/mem mmap constraints apply.
 
+    mmap of /proc/bus/pci/.../??.?
+
+    	This is an MMIO mmap of PCI functions, which additionally may or
+	may not be requested as using the WC attribute.
+
+	If WC is requested, and the region in kern_memmap is either WC
+	or UC, and the EFI memory map designates the region as WC, then
+	the WC mapping is allowed.
+
+	Otherwise, the user mapping must use the same attribute as the
+	kernel mapping.
+
     read/write of /dev/mem
 
 	This uses copy_from_user(), which implicitly uses a kernel
