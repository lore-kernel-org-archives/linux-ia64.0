From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 03 Aug 2004 17:52:07 +0000
Subject: [PATCH] small cleanup for per_hub_init()
Message-Id: <200408031052.07340.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_HD9DB2Hp+3lmyz/"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_HD9DB2Hp+3lmyz/
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Mark per_hub_init as __init and remove an unnecessary extern declaration of it 
in sgi_io_init.c.  This has the effect of killing a warning in the compile of 
that file.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_HD9DB2Hp+3lmyz/
Content-Type: text/plain;
  charset="us-ascii";
  name="per-hub-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="per-hub-cleanup.patch"

===== arch/ia64/sn/io/platform_init/sgi_io_init.c 1.9 vs edited =====
--- 1.9/arch/ia64/sn/io/platform_init/sgi_io_init.c	2004-05-11 08:25:13 -07:00
+++ edited/arch/ia64/sn/io/platform_init/sgi_io_init.c	2004-08-03 10:49:54 -07:00
@@ -37,7 +37,7 @@
  *
  * 	This code is executed once for each Hub chip.
  */
-static void
+static void __init
 per_hub_init(cnodeid_t cnode)
 {
 	nasid_t nasid;
@@ -130,10 +130,8 @@
 	klhwg_add_all_modules(hwgraph_root);
 	klhwg_add_all_nodes(hwgraph_root);
 
-	for (cnode = 0; cnode < numionodes; cnode++) {
-		extern void per_hub_init(cnodeid_t);
+	for (cnode = 0; cnode < numionodes; cnode++)
 		per_hub_init(cnode);
-	}
 
 	/*
 	 *

--Boundary-00=_HD9DB2Hp+3lmyz/--
