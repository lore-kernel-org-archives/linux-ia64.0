From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 17:56:50 +0000
Subject: [Linux-ia64] [PATCH] 2/3 sba_iommu vendor/function for unknown IOCs
Message-Id: <marc-linux-ia64-105590723705534@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This was in the 2.4.20 ia64 patch, but didn't make it when the
new sba_iommu code went into 2.5.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1053  -> 1.1054 
#	arch/ia64/hp/common/sba_iommu.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/17	bjorn_helgaas@hp.com	1.1054
# ia64: Include vendor/function ID for "Unknown" IOCs.
# --------------------------------------------
#
diff -Nru a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- a/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:43 2003
+++ b/arch/ia64/hp/common/sba_iommu.c	Thu Apr 17 11:29:43 2003
@@ -1669,8 +1669,15 @@
 		}
 	}
 
-	if (!ioc->name)
-		ioc->name = "Unknown";
+	if (!ioc->name) {
+		ioc->name = kmalloc(24, GFP_KERNEL);
+		if (ioc->name)
+			sprintf(ioc->name, "Unknown (%04x:%04x)",
+				ioc->func_id & 0xFFFF,
+				(ioc->func_id >> 16) & 0xFFFF);
+		else
+			ioc->name = "Unknown";
+	}
 
 	ioc_iova_init(ioc);
 	ioc_resource_init(ioc);


