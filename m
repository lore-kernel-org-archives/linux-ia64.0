From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 17:54:15 +0000
Subject: [Linux-ia64] [PATCH] 1/3 sba_iommu workaround removal
Message-Id: <marc-linux-ia64-105590723705533@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These patches are for 2.5 (against the to-linus-2.5 BK tree).

This removes a workaround for some broken firmware that was
never released.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1052  -> 1.1053 
#	arch/ia64/hp/common/sba_iommu.c	1.13    -> 1.14   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/17	bjorn_helgaas@hp.com	1.1053
# ia64: sba_iommu: remove workarounds for broken, never released, firmware that
# didn't program IBASE/IMASK correctly.
# --------------------------------------------
#
diff -Nru a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:32 2003
+++ b/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:32 2003
@@ -1430,20 +1430,6 @@
 	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & ~0x1UL;
 	ioc->iov_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
 
-	if (ioc->ibase = 0) {
-		if (((unsigned long) ioc->ioc_hpa & 0x3000UL) = 0x2000)
-			ioc->ibase = 0xc0000000;
-		else
-			ioc->ibase = 0x80000000;
-		printk("WARNING: IBASE is zero; setting to 0x%lx\n", ioc->ibase);
-	}
-
-	if (ioc->ibase < 0xfed00000UL && ioc->ibase + ioc->iov_size >= 0xfee00000UL) {
-		printk("WARNING: IOV space overlaps local config and interrupt message, "
-		       "truncating\n");
-		ioc->iov_size /= 2;
-	}
-
 	/*
 	** iov_order is always based on a 1GB IOVA space since we want to
 	** turn on the other half for AGP GART.


