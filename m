From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 26 May 2004 21:49:02 +0000
Subject: [PATCH] don't udelay() in sn_mmiob
Message-Id: <200405261749.02254.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ODRtAYBeqbEKKem"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_ODRtAYBeqbEKKem
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

sn_mmiob is a lightweight way to ensure PCI write ordering, intended to be 
used as an alternative to doing a PIO read.  Unfortunately, with the udelay() 
in there, it ends up being slower than a PCI read on small configurations, so 
remove it.

Thanks,
Jesse


--Boundary-00=_ODRtAYBeqbEKKem
Content-Type: text/x-diff;
  charset="us-ascii";
  name="no-udelay-mmiob.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="no-udelay-mmiob.patch"

===== arch/ia64/sn/io/machvec/iomv.c 1.8 vs edited =====
--- 1.8/arch/ia64/sn/io/machvec/iomv.c	Tue Sep 16 12:00:45 2003
+++ edited/arch/ia64/sn/io/machvec/iomv.c	Wed May 26 13:49:19 2004
@@ -71,6 +71,6 @@
 {
 	while ((((volatile unsigned long) (*pda->pio_write_status_addr)) & SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) != 
 				SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
-		udelay(1);
+		;
 }
 EXPORT_SYMBOL(sn_mmiob);

--Boundary-00=_ODRtAYBeqbEKKem--
