From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 12 Dec 2007 07:28:52 +0000
Subject: [PATCH] ia64: Remove compiler warnings on head.S
Message-Id: <475F8DB4.9040306@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <475F8A87.60802@jp.fujitsu.com>
In-Reply-To: <475F8A87.60802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

And another warning fix is here.

Thanks,
H.Seto

---
This patch removes the following compiler warning messages.

  AS      arch/ia64/kernel/head.o
arch/ia64/kernel/head.S: Assembler messages:
arch/ia64/kernel/head.S:1179: Warning: Use of 'ld8' violates RAW dependency 'CR[PTA]' (data)
arch/ia64/kernel/head.S:1179: Warning: Only the first path encountering the conflict is reported
arch/ia64/kernel/head.S:1178: Warning: This is the location of the conflicting usage
arch/ia64/kernel/head.S:1180: Warning: Use of 'ld8' violates RAW dependency 'CR[PTA]' (data)
arch/ia64/kernel/head.S:1180: Warning: Only the first path encountering the conflict is reported
arch/ia64/kernel/head.S:1178: Warning: This is the location of the conflicting usage
 :
arch/ia64/kernel/head.S:1213: Warning: Use of 'ldf.fill.nta' violates RAW dependency 'CR[PTA]' (data)
arch/ia64/kernel/head.S:1213: Warning: Only the first path encountering the conflict is reported
arch/ia64/kernel/head.S:1178: Warning: This is the location of the conflicting usage

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/head.S |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.24-rc5/arch/ia64/kernel/head.S
=================================--- linux-2.6.24-rc5.orig/arch/ia64/kernel/head.S
+++ linux-2.6.24-rc5/arch/ia64/kernel/head.S
@@ -1176,6 +1176,7 @@
 	RESTORE_REG(cr.dcr, r25, r17);;
 	RESTORE_REG(cr.iva, r25, r17);;
 	RESTORE_REG(cr.pta, r25, r17);;
+	srlz.d;;	// required not to violate RAW dependency
 	RESTORE_REG(cr.itv, r25, r17);;
 	RESTORE_REG(cr.pmv, r25, r17);;
 	RESTORE_REG(cr.cmcv, r25, r17);;
