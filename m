From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 17 Oct 2006 22:10:27 +0000
Subject: [Patch] remove some rsm psr.dt in ivt.S
Message-Id: <1161123027.2592.63.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The rsm psr.dt in page_not_present, key_permission, iaccess_rights and
daccess_right are not necessary. 
Since there is no data access between those points to page_fault, and
page_fault will enable psr.dt at the beginning.

Sign-off-by: Zou Nan hai <nanhai.zou@intel.com>

--- linux-2.6.18/arch/ia64/kernel/ivt.S	2006-10-18 00:15:11.000000000 +0800
+++ linux-2.6.18-fix/arch/ia64/kernel/ivt.S	2006-10-18 00:39:48.000000000 +0800
@@ -1201,7 +1201,6 @@ END(dispatch_to_fault_handler)
 ENTRY(page_not_present)
 	DBG_FAULT(20)
 	mov r16=cr.ifa
-	rsm psr.dt
 	/*
 	 * The Linux page fault handler doesn't expect non-present pages to be in
 	 * the TLB.  Flush the existing entry now, so we meet that expectation.
@@ -1211,7 +1210,6 @@ ENTRY(page_not_present)
 	ptc.l r16,r17
 	;;
 	mov r31=pr
-	srlz.d
 	br.sptk.many page_fault
 END(page_not_present)
 
@@ -1221,10 +1219,8 @@ END(page_not_present)
 ENTRY(key_permission)
 	DBG_FAULT(21)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
 	;;
-	srlz.d
 	br.sptk.many page_fault
 END(key_permission)
 
@@ -1234,10 +1230,8 @@ END(key_permission)
 ENTRY(iaccess_rights)
 	DBG_FAULT(22)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
 	;;
-	srlz.d
 	br.sptk.many page_fault
 END(iaccess_rights)
 
@@ -1247,10 +1241,8 @@ END(iaccess_rights)
 ENTRY(daccess_rights)
 	DBG_FAULT(23)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
 	;;
-	srlz.d
 	br.sptk.many page_fault
 END(daccess_rights)
 

