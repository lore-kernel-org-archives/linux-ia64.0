From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 19:05:05 +0000
Subject: [PATCH] fix sba_iommu build
Message-Id: <200410201205.05111.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_hbrdB/ruK22nefN"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_hbrdB/ruK22nefN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

sba_iommu.c needs to include linux/nodemask.h for node_online now.  Here's a 
patch to add it.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_hbrdB/ruK22nefN
Content-Type: text/plain;
  charset="us-ascii";
  name="sba-iommu-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sba-iommu-fix.patch"

===== arch/ia64/hp/common/sba_iommu.c 1.46 vs edited =====
--- 1.46/arch/ia64/hp/common/sba_iommu.c	2004-10-05 11:30:38 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2004-10-20 12:00:32 -07:00
@@ -33,6 +33,7 @@
 #include <linux/seq_file.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
+#include <linux/nodemask.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>

--Boundary-00=_hbrdB/ruK22nefN--
