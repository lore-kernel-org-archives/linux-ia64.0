From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 23:47:00 +0000
Subject: [PATCH] clear all region registers at boot
Message-Id: <200501071547.00751.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_09x3BqnroY/9J2N"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_09x3BqnroY/9J2N
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

If we initialize *all* of the region registers to be non-identity mapped we 
can catch a few more bugs that might be covered up by whatever their previous 
state was.  This patch sets them all up to use VHPT (i.e. non alt-tlb) 
address translation.  It already helped me find one bug in the sn2 
initialization code.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_09x3BqnroY/9J2N
Content-Type: text/plain;
  charset="us-ascii";
  name="init-all-rrs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="init-all-rrs.patch"

===== arch/ia64/kernel/head.S 1.28 vs edited =====
--- 1.28/arch/ia64/kernel/head.S	2004-08-18 11:17:23 -07:00
+++ edited/arch/ia64/kernel/head.S	2005-01-07 15:43:10 -08:00
@@ -65,10 +65,27 @@
 	;;
 	/*
 	 * Initialize kernel region registers:
+	 *	rr[0]: VHPT enabled, page size = PAGE_SHIFT
+	 *	rr[1]: VHPT enabled, page size = PAGE_SHIFT
+	 *	rr[2]: VHPT enabled, page size = PAGE_SHIFT
+	 *	rr[3]: VHPT enabled, page size = PAGE_SHIFT
+	 *	rr[4]: VHPT enabled, page size = PAGE_SHIFT
 	 *	rr[5]: VHPT enabled, page size = PAGE_SHIFT
 	 *	rr[6]: VHPT disabled, page size = IA64_GRANULE_SHIFT
 	 *	rr[7]: VHPT disabled, page size = IA64_GRANULE_SHIFT
+	 * We initialize all of them to prevent inadvertently assuming
+	 * something about the state of address translation early in boot.
 	 */
+	mov r6=((ia64_rid(IA64_REGION_ID_KERNEL, (0<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
+	movl r7=(0<<61)
+	mov r8=((ia64_rid(IA64_REGION_ID_KERNEL, (1<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
+	movl r9=(1<<61)
+	mov r10=((ia64_rid(IA64_REGION_ID_KERNEL, (2<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
+	movl r11=(2<<61)
+	mov r12=((ia64_rid(IA64_REGION_ID_KERNEL, (3<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
+	movl r13=(3<<61)
+	mov r14=((ia64_rid(IA64_REGION_ID_KERNEL, (4<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
+	movl r15=(4<<61)
 	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, (5<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
 	movl r17=(5<<61)
 	mov r18=((ia64_rid(IA64_REGION_ID_KERNEL, (6<<61)) << 8) | (IA64_GRANULE_SHIFT << 2))
@@ -76,6 +93,11 @@
 	mov r20=((ia64_rid(IA64_REGION_ID_KERNEL, (7<<61)) << 8) | (IA64_GRANULE_SHIFT << 2))
 	movl r21=(7<<61)
 	;;
+	mov rr[r7]=r6
+	mov rr[r9]=r8
+	mov rr[r11]=r10
+	mov rr[r13]=r12
+	mov rr[r15]=r14
 	mov rr[r17]=r16
 	mov rr[r19]=r18
 	mov rr[r21]=r20

--Boundary-00=_09x3BqnroY/9J2N--
