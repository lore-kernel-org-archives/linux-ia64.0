From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 17:59:12 +0000
Subject: [Linux-ia64] [PATCH] 3/3 sba_iommu trivial cleanup
Message-Id: <marc-linux-ia64-105590723705535@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is mostly trivial whitespace and printk text tweaks.  I did add the
segment number to a printk that previously just had the bus.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1054  -> 1.1055 
#	arch/ia64/hp/common/sba_iommu.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/17	bjorn_helgaas@hp.com	1.1055
# ia64: sba_iommu: whitespace, comment, and printk changes.
# --------------------------------------------
#
diff -Nru a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:54 2003
+++ b/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:54 2003
@@ -1437,7 +1437,7 @@
 	iov_order = get_order(ioc->iov_size >> (IOVP_SHIFT - PAGE_SHIFT));
 	ioc->pdir_size = (ioc->iov_size / IOVP_SIZE) * sizeof(u64);
 
-	DBG_INIT("%s() hpa %p IOV %dMB (%d bits) PDIR size 0x%0x\n",
+	DBG_INIT("%s() hpa %p IOV %dMB (%d bits) PDIR size 0x%x\n",
 		 __FUNCTION__, ioc->ioc_hpa, ioc->iov_size >> 20,
 		 iov_order + PAGE_SHIFT, ioc->pdir_size);
 
@@ -1521,9 +1521,9 @@
 	if (agp_found && reserve_sba_gart) {
 		DBG_INIT("%s: AGP device found, reserving half of IOVA for GART support\n",
 			 __FUNCTION__);
-  		ioc->pdir_size /= 2;
+		ioc->pdir_size /= 2;
 		((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] = ZX1_SBA_IOMMU_COOKIE;
-  	}
+	}
 #ifdef FULL_VALID_PDIR
 	/*
   	** Check to see if the spill page has been allocated, we don't need more than
@@ -1684,7 +1684,7 @@
 	ioc_sac_init(ioc);
 
 	printk(KERN_INFO PFX
-		"Found %s IOC %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
+		"%s %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
 		ioc->name, (ioc->rev >> 4) & 0xF, ioc->rev & 0xF,
 		hpa, ioc->iov_size >> 20, ioc->ibase);
 
@@ -1813,7 +1813,7 @@
 	if (ioc_list) {
 		struct proc_dir_entry * proc_mckinley_root;
 
-		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
+		proc_mckinley_root = proc_mkdir("bus/mckinley", 0);
 		create_proc_info_entry(ioc_list->name, 0, proc_mckinley_root, sba_proc_info);
 		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
 	}
@@ -1853,7 +1853,7 @@
 		handle = parent;
 	} while (ACPI_SUCCESS(status));
 
-	printk("No IOC for PCI Bus %d in ACPI\n", bus->number);
+	printk(KERN_WARNING "No IOC for PCI Bus %02x:%02x in ACPI\n", PCI_SEGMENT(bus), bus->number);
 }
 
 static int __init
@@ -1864,10 +1864,6 @@
 	u64 hpa, length;
 	struct acpi_device_info dev_info;
 
-	/*
-	 * Only SBA appears in ACPI namespace.  It encloses the PCI
-	 * root bridges, and its CSR space includes the IOC function.
-	 */
 	status = hp_acpi_csr_space(device->handle, &hpa, &length);
 	if (ACPI_FAILURE(status))
 		return 1;
@@ -1876,6 +1872,10 @@
 	if (ACPI_FAILURE(status))
 		return 1;
 
+	/*
+	 * For HWP0001, only SBA appears in ACPI namespace.  It encloses the PCI
+	 * root bridges, and its CSR space includes the IOC function.
+	 */
 	if (strncmp("HWP0001", dev_info.hardware_id, 7) = 0)
 		hpa += ZX1_IOC_OFFSET;
 


