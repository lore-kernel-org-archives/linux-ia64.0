From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 04 May 2005 13:42:28 +0000
Subject: [patch] fix scratch-regs in coredumps
Message-Id: <200505041342.j44DgSd2024138@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please feed into 2.6.12.

Thanks,

	--david

[IA64] Avoid .spillpsp directive in handcoded assembly

Some time ago, GAS was fixed to bring the .spillpsp directive in line
with the Intel assembler manual (there was some disagreement as to
whether or not there is a built-in 16-byte offset).  Unfortunately,
there are two places in the kernel where this directive is used in
handwritten assembly files and those of course relied on the "buggy"
behavior.  As a result, when using a "fixed" assembler, the kernel
picks up the UNaT bits from the wrong place (off by 16) and randomly
sets NaT bits on the scratch registers.  This can be noticed easily by
looking at a coredump and finding various scratch registers with
unexpected NaT values.  The patch below fixes this by using the
.spillsp directive instead, which works correctly no matter what
assembler is in use.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/entry.S
=================================--- a1717d536f9c023b43890c1f211a4cf1307078e9/arch/ia64/kernel/entry.S  (mode:100644 sha1:fd23b762b6959d0338a8a0b89065f79a9d07dbfc)
+++ uncommitted/arch/ia64/kernel/entry.S  (mode:100644)
@@ -1179,7 +1179,7 @@
 	;;
 (pNonSys) mov out2=0				// out2=0 => not a syscall
 	.fframe 16
-	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
+	.spillsp ar.unat, 16
 	st8 [sp]=r9,-16				// allocate space for ar.unat and save it
 	st8 [out1]=loc1,-8			// save ar.pfs, out1=&sigscratch
 	.body
@@ -1205,7 +1205,7 @@
 	adds out2=8,sp				// out2=&sigscratch->ar_pfs
 	;;
 	.fframe 16
-	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
+	.spillsp ar.unat, 16
 	st8 [sp]=r9,-16				// allocate space for ar.unat and save it
 	st8 [out2]=loc1,-8			// save ar.pfs, out2=&sigscratch
 	.body
