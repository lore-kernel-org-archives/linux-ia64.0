From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 10 Aug 2004 00:35:47 +0000
Subject: [PATCH] kill warning in bte.c
Message-Id: <200408091735.47593.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_jhBGBmS/oieHItU"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_jhBGBmS/oieHItU
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Robin or Dean, feel free to veto this one if it's not valid.  A recent patch 
caused a warning about not using expressions as lvalues to crop up in bte.c 
(or maybe it's just that I'm using gcc-3.4.1 now).  This patch fixes it by 
creating a temporary to store the register whose address we want to get and 
stuff into the per-bte info structure.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_jhBGBmS/oieHItU
Content-Type: text/plain;
  charset="us-ascii";
  name="bte-warning-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="bte-warning-fix.patch"

===== arch/ia64/sn/kernel/bte.c 1.7 vs edited =====
--- 1.7/arch/ia64/sn/kernel/bte.c	2004-07-30 14:05:59 -07:00
+++ edited/arch/ia64/sn/kernel/bte.c	2004-08-09 14:41:24 -07:00
@@ -421,9 +421,10 @@
 	mynodepda->bte_recovery_timer.data = (unsigned long) mynodepda;
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
-		(u64) mynodepda->bte_if[i].bte_base_addr =
-		    REMOTE_HUB_ADDR(cnodeid_to_nasid(cnode),
-			(i == 0 ? IIO_IBLS0 : IIO_IBLS1));
+		/* Which link status register should we use? */
+		unsigned long link_status = (i == 0 ? IIO_IBLS0 : IIO_IBLS1);
+		mynodepda->bte_if[i].bte_base_addr = (u64 *)
+			REMOTE_HUB_ADDR(cnodeid_to_nasid(cnode), link_status);
 
 		/*
 		 * Initialize the notification and spinlock

--Boundary-00=_jhBGBmS/oieHItU--
