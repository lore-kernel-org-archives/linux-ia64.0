From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 16 Nov 2004 01:22:41 +0000
Subject: [PATCH] fix phys. address conversion in ia64_pal_tr_read
Message-Id: <200411151722.41157.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_hZVmBbcZ25tKeOu"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_hZVmBbcZ25tKeOu
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The palinfo module may call ia64_pal_tr_read using an IPI.  If the processor 
receiving the IPI is idle, the call will fail since the idle process stack is 
in region 5 and ia64_pal_tr_read uses __pa rather than ia64_tpa.  This small 
patch fixes the problem by making it use ia64_tpa instead.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_hZVmBbcZ25tKeOu
Content-Type: text/plain;
  charset="us-ascii";
  name="tr-info-fix-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tr-info-fix-2.patch"

===== include/asm-ia64/pal.h 1.9 vs edited =====
--- 1.9/include/asm-ia64/pal.h	2003-11-25 00:23:21 -08:00
+++ edited/include/asm-ia64/pal.h	2004-11-15 17:07:51 -08:00
@@ -1531,7 +1531,7 @@
 ia64_pal_tr_read (u64 reg_num, u64 tr_type, u64 *tr_buffer, pal_tr_valid_u_t *tr_valid)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL_PHYS_STK(iprv, PAL_VM_TR_READ, reg_num, tr_type,(u64)__pa(tr_buffer));
+	PAL_CALL_PHYS_STK(iprv, PAL_VM_TR_READ, reg_num, tr_type,(u64)ia64_tpa(tr_buffer));
 	if (tr_valid)
 		tr_valid->piv_val = iprv.v0;
 	return iprv.status;

--Boundary-00=_hZVmBbcZ25tKeOu--
