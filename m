From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 05:00:05 +0000
Subject: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <200501190500.j0J505jY002441@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

$SUBJECT says it all...

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 17:46:04-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
#   	Drops normal getpid() from 275 down to 271 cycles.
# 
# arch/ia64/kernel/entry.S
#   2005/01/18 17:45:52-08:00 davidm@tiger.hpl.hp.com +26 -16
#   (skip_rbs_switch): Reschedule to run 4 cycles faster on McKinley-type cores
#   	(drops normal getpid() from 275 down to 271 cycles).
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 20:58:43 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 20:58:43 -08:00
@@ -1032,23 +1032,33 @@
 	loadrs
 	;;
 skip_rbs_switch:
-(pLvSys)	mov r19=r0		// clear r19 for leave_syscall, no-op otherwise
-	mov b0=r21
-	mov ar.pfs=r26
-(pUStk)	mov ar.bspstore=r23
-(p9)	mov cr.ifs=r30
-(pLvSys)mov r16=r0		// clear r16 for leave_syscall, no-op otherwise
-	mov cr.ipsr=r29
-	mov ar.fpsr=r20
-(pLvSys)mov r17=r0		// clear r17 for leave_syscall, no-op otherwise
-	mov cr.iip=r28
+	mov ar.unat=r25		// M2
+	nop.i 0			// I0
+(pLvSys)mov r19=r0		// A  clear r19 for leave_syscall, no-op otherwise
 	;;
-(pUStk)	mov ar.rnat=r24		// must happen with RSE in lazy mode
-(pLvSys)mov r18=r0		// clear r18 for leave_syscall, no-op otherwise
-	mov ar.rsc=r27
-	mov ar.unat=r25
-	mov pr=r31,-1
-	rfi
+(pUStk)	mov ar.bspstore=r23	// M2
+	nop.i 0			// I0
+(pLvSys)mov r16=r0		// A  clear r16 for leave_syscall, no-op otherwise
+	;;
+	mov cr.ipsr=r29		// M2
+	mov ar.pfs=r26		// I0
+(pLvSys)mov r17=r0		// A  clear r17 for leave_syscall, no-op otherwise
+
+(p9)	mov cr.ifs=r30		// M2
+	mov b0=r21		// I0
+(pLvSys)mov r18=r0		// A  clear r18 for leave_syscall, no-op otherwise
+
+	mov ar.fpsr=r20		// M2
+	mov cr.iip=r28		// M2
+	nop 0
+	;;
+(pUStk)	mov ar.rnat=r24		// M2 must happen with RSE in lazy mode
+	nop 0
+	nop 0
+
+	mov ar.rsc=r27		// M2
+	mov pr=r31,-1		// I0
+	rfi			// B
 
 	/*
 	 * On entry:
