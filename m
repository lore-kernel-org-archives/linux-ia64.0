From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 05:55:42 +0000
Subject: [patch] fix stray backslash
Message-Id: <200503240555.j2O5tgLW023251@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial fix to drop a stray backslash in the
MINSTATE_START_SAVE_MIN_VIRT macro.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/minstate.h 1.19 vs edited ==--- 1.19/arch/ia64/kernel/minstate.h	2005-01-26 10:01:31 -08:00
+++ edited/arch/ia64/kernel/minstate.h	2005-03-23 21:46:39 -08:00
@@ -26,7 +26,7 @@
 (pKStk) addl r1=-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r12) */	\
 	;;											\
 (pUStk)	mov r18=ar.bsp;										\
-(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */		\
+(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */
 
 #define MINSTATE_END_SAVE_MIN_VIRT								\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
