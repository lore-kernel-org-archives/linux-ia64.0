From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Thu, 22 Nov 2007 03:15:55 +0000
Subject: [PATCH RFC][try 2] IA64 signal : remove redundant code in setup_sigcontext()
Message-Id: <4744F46B.6050004@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org

This patch removes some redundant code in the function setup_sigcontext().

The registers ar.ccv,b7,r14,ar.csd,ar.ssd,r2-r3 and r16-r31 are not restored 
in restore_sigcontext() when (flags & IA64_SC_FLAG_IN_SYSCALL) is true. 
So we don't need to zero those variables in setup_sigcontext().

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 

---
diff -urp linux-2.6.24-rc3-git1.orig/arch/ia64/kernel/signal.c linux-2.6.24-rc3-git1/arch/ia64/kernel/signal.c
--- linux-2.6.24-rc3-git1.orig/arch/ia64/kernel/signal.c	2007-11-17 13:16:36.000000000 +0800
+++ linux-2.6.24-rc3-git1/arch/ia64/kernel/signal.c	2007-11-22 11:02:27.000000000 +0800
@@ -280,15 +280,7 @@ setup_sigcontext (struct sigcontext __us
 	err |= __copy_to_user(&sc->sc_gr[15], &scr->pt.r15, 8);		/* r15 */
 	err |= __put_user(scr->pt.cr_iip + ia64_psr(&scr->pt)->ri, &sc->sc_ip);
 
-	if (flags & IA64_SC_FLAG_IN_SYSCALL) {
-		/* Clear scratch registers if the signal interrupted a system call. */
-		err |= __put_user(0, &sc->sc_ar_ccv);				/* ar.ccv */
-		err |= __put_user(0, &sc->sc_br[7]);				/* b7 */
-		err |= __put_user(0, &sc->sc_gr[14]);				/* r14 */
-		err |= __clear_user(&sc->sc_ar25, 2*8);			/* ar.csd & ar.ssd */
-		err |= __clear_user(&sc->sc_gr[2], 2*8);			/* r2-r3 */
-		err |= __clear_user(&sc->sc_gr[16], 16*8);			/* r16-r31 */
-	} else {
+	if (!(flags & IA64_SC_FLAG_IN_SYSCALL)) {
 		/* Copy scratch regs to sigcontext if the signal didn't interrupt a syscall. */
 		err |= __put_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);		/* ar.ccv */
 		err |= __put_user(scr->pt.b7, &sc->sc_br[7]);			/* b7 */

