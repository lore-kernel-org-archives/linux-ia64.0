From: akpm@linux-foundation.org
Date: Thu, 13 Dec 2007 23:58:26 +0000
Subject: [patch 2/3] IA64 signal: remove redundant code in setup_sigcontext()
Message-Id: <200712132358.lBDNwQ7r025176@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Shi Weihua <shiwh@cn.fujitsu.com>

This patch removes some redundant code in the function setup_sigcontext().

The registers ar.ccv,b7,r14,ar.csd,ar.ssd,r2-r3 and r16-r31 are not
restored in restore_sigcontext() when (flags & IA64_SC_FLAG_IN_SYSCALL) is
true.  So we don't need to zero those variables in setup_sigcontext().

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/signal.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff -puN arch/ia64/kernel/signal.c~ia64-signal-remove-redundant-code-in-setup_sigcontext arch/ia64/kernel/signal.c
--- a/arch/ia64/kernel/signal.c~ia64-signal-remove-redundant-code-in-setup_sigcontext
+++ a/arch/ia64/kernel/signal.c
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
_
