From: Keith Owens <kaos@sgi.com>
Date: Thu, 16 Sep 2004 06:20:59 +0000
Subject: [patch 2.6.9-test] Remove remnants of ar.k[56] being physical
Message-Id: <9317.1095315659@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ar.k[56] used to contain physical addresses but now contain virtual
addresses.  There are code remnants which still believe that they are
physical and "convert" ar.k[56] to virtual.  This breaks when current
is not in region 7 (e.g. the idle task on cpu 0).

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/minstate.h
=================================--- linux.orig/arch/ia64/kernel/minstate.h	Thu Sep 16 12:25:31 2004
+++ linux/arch/ia64/kernel/minstate.h	Thu Sep 16 15:05:22 2004
@@ -54,8 +54,6 @@
 (pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */		\
 
 #define MINSTATE_END_SAVE_MIN_PHYS								\
-	or r12=r12,r14;		/* make sp a kernel virtual address */				\
-	or r13=r13,r14;		/* make `current' a kernel virtual address */			\
 	;;
 
 #ifdef MINSTATE_VIRT
@@ -172,7 +170,6 @@
 	;;											\
 .mem.offset 0,0; st8.spill [r16]=r15,16;							\
 .mem.offset 8,0; st8.spill [r17]=r14,16;							\
-	dep r14=-1,r0,61,3;									\
 	;;											\
 .mem.offset 0,0; st8.spill [r16]=r2,16;								\
 .mem.offset 8,0; st8.spill [r17]=r3,16;								\
Index: linux/include/asm-ia64/mca_asm.h
=================================--- linux.orig/include/asm-ia64/mca_asm.h	Sat Aug 14 15:37:55 2004
+++ linux/include/asm-ia64/mca_asm.h	Thu Sep 16 14:38:26 2004
@@ -162,9 +162,6 @@
 	;;							\
 	srlz.d;							\
 	mov	r13 = ar.k6;					\
-	;;							\
-	DATA_PA_TO_VA(r13,temp1);				\
-	;;							\
 	mov	temp2 = ar.bspstore;				\
 	;;							\
 	DATA_PA_TO_VA(temp2,temp1);				\

