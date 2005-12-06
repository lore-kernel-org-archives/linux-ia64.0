From: Jack Steiner <steiner@sgi.com>
Date: Tue, 06 Dec 2005 14:05:24 +0000
Subject: [PATCH] - Fix SN PTC deadlock recovery
Message-Id: <20051206140524.GA32456@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch that added support for a new platform chipset (shub2) broke
PTC deadlock recovery on older versions of the chipset. (PTCs are the
SN platform-specific method for doing a global TLB purge). This
patch fixes deadlock recovery so that it works on both the old & new 
chipsets.


	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2005-12-01 11:41:02.394548556 -0600
+++ linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2005-12-06 07:59:32.176021944 -0600
@@ -39,9 +39,13 @@ sn2_ptc_deadlock_recovery_core:
 	mov	r8=r0
 
 1:
+	cmp.ne  p8,p9=r0,ptc1		// Test for shub type (ptc1 non-null on shub1)
+					// p8 = 1 if shub1, p9 = 1 if shub2
+
 	add	scr2=ALIAS_OFFSET,piowc	// Address of WRITE_STATUS alias register 
-	;;
-	ld8.acq	scr1=[scr2];;
+	mov	scr1=7;;		// Clear DEADLOCK, WRITE_ERROR, MULTI_WRITE_ERROR
+(p8)	st8.rel	[scr2]=scr1;;
+(p9)	ld8.acq	scr1=[scr2];;
 
 5:	ld8.acq	scr1=[piowc];;		// Wait for PIOs to complete.
 	hint	@pause
