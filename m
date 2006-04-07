From: Keith Owens <kaos@sgi.com>
Date: Fri, 07 Apr 2006 06:34:34 +0000
Subject: [patch 2.6.16] Failure to resume after INIT in user space
Message-Id: <23577.1144391674@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The OS INIT handler is loading incorrect values into cr.ifa on exit.
This shows up as a hang when resuming after an INIT that is delivered
while a cpu is in user space.  Correct the value loaded into cr.ifa.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/mca_asm.S |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2006-04-07 16:17:11.000000000 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2006-04-07 16:21:10.690447179 +1000
@@ -827,7 +827,7 @@ ia64_state_restore:
 	ld8 r9=[temp2],16	// sal_gp
 	;;
 	ld8 r22=[temp1],16	// pal_min_state, virtual
-	ld8 r21=[temp2],16	// prev_IA64_KR_CURRENT
+	ld8 r13=[temp2],16	// prev_IA64_KR_CURRENT
 	;;
 	ld8 r16=[temp1],16	// prev_IA64_KR_CURRENT_STACK
 	ld8 r20=[temp2],16	// prev_task
@@ -848,7 +848,7 @@ ia64_state_restore:
 	mov cr.iim=temp3
 	mov cr.iha=temp4
 	dep r22=0,r22,62,1	// pal_min_state, physical, uncached
-	mov IA64_KR(CURRENT)=r21
+	mov IA64_KR(CURRENT)=r13
 	ld8 r8=[temp1]		// os_status
 	ld8 r10=[temp2]		// context
 
@@ -856,7 +856,7 @@ ia64_state_restore:
 	 * avoid any dependencies on the algorithm in ia64_switch_to(), just
 	 * purge any existing CURRENT_STACK mapping and insert the new one.
 	 *
-	 * r16 contains prev_IA64_KR_CURRENT_STACK, r21 contains
+	 * r16 contains prev_IA64_KR_CURRENT_STACK, r13 contains
 	 * prev_IA64_KR_CURRENT, these values may have been changed by the C
 	 * code.  Do not use r8, r9, r10, r22, they contain values ready for
 	 * the return to SAL.
@@ -873,7 +873,7 @@ ia64_state_restore:
 	;;
 	srlz.d
 
-	extr.u r19=r21,61,3			// r21 = prev_IA64_KR_CURRENT
+	extr.u r19=r13,61,3			// r13 = prev_IA64_KR_CURRENT
 	shl r20=r16,IA64_GRANULE_SHIFT		// r16 = prev_IA64_KR_CURRENT_STACK
 	movl r21=PAGE_KERNEL			// page properties
 	;;
@@ -883,7 +883,7 @@ ia64_state_restore:
 (p6)	br.spnt 1f				// the dreaded cpu 0 idle task in region 5:(
 	;;
 	mov cr.itir=r18
-	mov cr.ifa=r21
+	mov cr.ifa=r13
 	mov r20=IA64_TR_CURRENT_STACK
 	;;
 	itr.d dtr[r20]=r21

