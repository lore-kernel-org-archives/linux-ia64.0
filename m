From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:50:42 +0000
Subject: syscall improvement patch [5/12]
Message-Id: <200503240050.j2O0ogwk022286@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: In syscall-entry, use st8 instead of stf8 to clear pt_regs.r8.

Using stf8 seemed like a clever idea at the time, but stf8 forces
the cache-line to be invalidated in the L1D (if it happens to be
there already).  This patch eliminates a guaranteed L1D cache-miss
and, by itself, is good for a 1-2 cycle improvement for heavy-weight
syscalls.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	2005-03-23 13:48:52 -08:00
+++ b/arch/ia64/kernel/ivt.S	2005-03-23 13:48:52 -08:00
@@ -1,7 +1,7 @@
 /*
  * arch/ia64/kernel/ivt.S
  *
- * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003, 2005 Hewlett-Packard Co
  *	Stephane Eranian <eranian@hpl.hp.com>
  *	David Mosberger <davidm@hpl.hp.com>
  * Copyright (C) 2000, 2002-2003 Intel Co
@@ -918,7 +918,7 @@
 	tnat.nz p14,p0=3Din6
 	cmp.lt p10,p9=3Dr11,r8	// frame size can't be more than local+8
 	;;
-	stf8 [r16]=F1		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
+	mov r8=3D1
 (p9)	tnat.nz p10,p0=3Dr15
 	adds r12=3D-16,r1		// switch to kernel memory stack (with 16 bytes of scr=
atch)
=20
@@ -929,9 +929,9 @@
 	mov r13=3Dr2				// establish `current'
 	movl r1=3D__gp				// establish kernel global pointer
 	;;
+	st8 [r16]=3Dr8		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
 (p14)	mov in6=3D-1
 (p8)	mov in7=3D-1
-	nop.i 0
=20
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
 	movl r17=3DFPSR_DEFAULT
