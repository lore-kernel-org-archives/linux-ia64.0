From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 16 Feb 2001 04:28:48 +0000
Subject: [Linux-ia64] setjmp cleanup
Message-Id: <marc-linux-ia64-105590693005155@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch to remove the unnecessary "loadrs" from setjmp.

	--david

2001-02-15  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/unix/sysv/linux/ia64/__longjmp.S (__longjmp): No need to
	do "loadrs".  Writing to bspstore already takes care of
	invalidating the "clean" partition.

Index: sysdeps/unix/sysv/linux/ia64/__longjmp.S
=================================RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/ia64/__longjmp.S,v
retrieving revision 1.1
diff -u -r1.1 __longjmp.S
--- __longjmp.S	2000/06/10 00:14:40	1.1
+++ __longjmp.S	2001/02/16 04:26:46
@@ -67,7 +67,6 @@
 	and r8=0x3f,r8
 	;;
 	cmp.lt pNeg,pPos=r8,r0
-	dep r11=r0,r11,16,14	// clear ar.rsc.loadrs
 	mov r2=in0
 	;;
 (pPos)	mov r16=r8
@@ -117,7 +116,6 @@
 	ld8.nta r11=[r2],16		// ar.pfs
 	ld8.nta r22=[r3],56		// ar.lc
 	;;
-	loadrs			// invalidate stacked regs (must be first in insn group)
 	ld8.nta r24=[r2],32		// pr
 	mov b0=r16
 	;;

