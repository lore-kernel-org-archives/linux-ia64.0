From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 08 Sep 2003 01:17:09 +0000
Subject: arch/ia64/hp/common/sba_iommu.c should include version.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Message-Id: <marc-linux-ia64-106298384827966@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

As it uses version macros.  

This fix allows Linus bk tree to build.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au



--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sba_iommu.c.diff"

===== arch/ia64/hp/common/sba_iommu.c 1.29 vs edited =====
--- 1.29/arch/ia64/hp/common/sba_iommu.c	Mon Sep  1 09:14:08 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Sep  8 11:02:04 2003
@@ -33,6 +33,7 @@
 #include <linux/seq_file.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
+#include <linux/version.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>

--qMm9M+Fa2AknHoGS--
