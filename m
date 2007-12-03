From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Mon, 03 Dec 2007 04:57:50 +0000
Subject: [PATCH] IA64 signal : fix missing error checkings
Message-Id: <47538CCE.90607@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org

Not all the return value of __copy_from_user and
__put_user is checked.This patch fixed it.

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 

---
diff -x '*.o*' -urp linux-2.6.24-rc3-git6.orig/arch/ia64/kernel/signal.c linux-2.6.24-rc3-git6/arch/ia64/kernel/signal.c
--- linux-2.6.24-rc3-git6.orig/arch/ia64/kernel/signal.c	2007-12-03 12:04:22.000000000 +0800
+++ linux-2.6.24-rc3-git6/arch/ia64/kernel/signal.c	2007-12-03 12:50:15.000000000 +0800
@@ -98,7 +98,7 @@ restore_sigcontext (struct sigcontext __
 	if ((flags & IA64_SC_FLAG_FPH_VALID) != 0) {
 		struct ia64_psr *psr = ia64_psr(&scr->pt);
 
-		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
+		err |= __copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
 		psr->mfh = 0;	/* drop signal handler's fph contents... */
 		preempt_disable();
 		if (psr->dfh)
@@ -244,7 +244,7 @@ static long
 setup_sigcontext (struct sigcontext __user *sc, sigset_t *mask, struct sigscratch *scr)
 {
 	unsigned long flags = 0, ifs, cfm, nat;
-	long err;
+	long err = 0;
 
 	ifs = scr->pt.cr_ifs;
 
@@ -257,12 +257,12 @@ setup_sigcontext (struct sigcontext __us
 	ia64_flush_fph(current);
 	if ((current->thread.flags & IA64_THREAD_FPH_VALID)) {
 		flags |= IA64_SC_FLAG_FPH_VALID;
-		__copy_to_user(&sc->sc_fr[32], current->thread.fph, 96*16);
+		err = __copy_to_user(&sc->sc_fr[32], current->thread.fph, 96*16);
 	}
 
 	nat = ia64_get_scratch_nat_bits(&scr->pt, scr->scratch_unat);
 
-	err  = __put_user(flags, &sc->sc_flags);
+	err |= __put_user(flags, &sc->sc_flags);
 	err |= __put_user(nat, &sc->sc_nat);
 	err |= PUT_SIGSET(mask, &sc->sc_mask);
 	err |= __put_user(cfm, &sc->sc_cfm);

