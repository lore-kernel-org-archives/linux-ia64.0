From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 17:16:13 +0000
Subject: [PATCH] sparse cleanup for mca.c
Message-Id: <200410201016.13798.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_d1pdB1fXXx6+guv"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_d1pdB1fXXx6+guv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Looks like we were casting a value into a union and sparse doesn't like that.  
Why not just assign it directly to the appropriate field?

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_d1pdB1fXXx6+guv
Content-Type: text/plain;
  charset="us-ascii";
  name="sparse-mca-fixups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sparse-mca-fixups.patch"

===== arch/ia64/kernel/mca.c 1.69 vs edited =====
--- 1.69/arch/ia64/kernel/mca.c	2004-09-30 11:49:13 -07:00
+++ edited/arch/ia64/kernel/mca.c	2004-10-20 09:27:20 -07:00
@@ -593,7 +593,7 @@
 {
 	cmcv_reg_t	cmcv;
 
-	cmcv = (cmcv_reg_t)ia64_getreg(_IA64_REG_CR_CMCV);
+	cmcv.cmcv_regval = ia64_getreg(_IA64_REG_CR_CMCV);
 
 	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
@@ -620,7 +620,7 @@
 {
 	cmcv_reg_t	cmcv;
 
-	cmcv = (cmcv_reg_t)ia64_getreg(_IA64_REG_CR_CMCV);
+	cmcv.cmcv_regval = ia64_getreg(_IA64_REG_CR_CMCV);
 
 	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);

--Boundary-00=_d1pdB1fXXx6+guv--
