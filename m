From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 25 Oct 2006 04:25:59 +0000
Subject: [Patch] IA64 Kdump Fix fc.i offset in relocate_kernel.S
Message-Id: <1161750359.2592.3.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,
	This patch is against your test tree.
	There is 8 byte wrong offset in icache flush instruction in
relocate_kernel.S. Which may cause normal
Kexec(not kdump) fail on Montecito Box.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

--- linux-2.6/arch/ia64/kernel/relocate_kernel.S	2006-10-25 14:37:30.000000000 +0800
+++ b/arch/ia64/kernel/relocate_kernel.S	2006-10-25 14:45:59.000000000 +0800
@@ -166,8 +166,9 @@ GLOBAL_ENTRY(relocate_new_kernel)
 	mov ar.lc=r14;;
 1:
 	ld8 r14=[r18], 8;;
-	st8 [r17]=r14, 8;;
+	st8 [r17]=r14;;
 	fc.i r17
+	add r17=8, r17
 	br.ctop.sptk.few 1b
 	br.sptk.few .loop
 	;;

