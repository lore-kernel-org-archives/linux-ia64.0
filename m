From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 20 Jul 2004 19:44:18 +0000
Subject: [PATCH] sn2 requires a 3.40 or better PROM
Message-Id: <200407201544.18841.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_SYX/AAWbVvmjB+p"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_SYX/AAWbVvmjB+p
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The SGI 3.40 PROM includes a fix for the move of the init_task to region 5, so 
specify that in sn_sal.h.  Unfortunately, the check for the minimum required 
version happens *after* the hang/MCA that is symptomatic of the bug, so this 
message also acts as an announcement of the requirement.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_SYX/AAWbVvmjB+p
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn-sal-min-3.40.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn-sal-min-3.40.patch"

===== include/asm-ia64/sn/sn_sal.h 1.9 vs edited =====
--- 1.9/include/asm-ia64/sn/sn_sal.h	2004-06-16 06:14:42 -07:00
+++ edited/include/asm-ia64/sn/sn_sal.h	2004-07-20 12:35:37 -07:00
@@ -141,8 +141,8 @@
  * Specify the minimum PROM revsion required for this kernel.
  * Note that they're stored in hex format...
  */
-#define SN_SAL_MIN_MAJOR	0x1  /* SN2 kernels need at least PROM 1.0 */
-#define SN_SAL_MIN_MINOR	0x0
+#define SN_SAL_MIN_MAJOR	0x3  /* SN2 kernels need at least PROM 3.40 */
+#define SN_SAL_MIN_MINOR	0x40
 
 u64 ia64_sn_probe_io_slot(long paddr, long size, void *data_ptr);
 

--Boundary-00=_SYX/AAWbVvmjB+p--
