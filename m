From: Keith Owens <kaos@sgi.com>
Date: Fri, 01 Jul 2005 05:52:56 +0000
Subject: [patch 2.6.13-rc1] restore_sigcontext is not preempt safe
Message-Id: <8043.1120197176@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

restore_sigcontext calls ia64_set_local_fpu_owner() which requires that
preempt be disabled.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/signal.c
=================================--- linux.orig/arch/ia64/kernel/signal.c	2005-07-01 12:27:44.891940980 +1000
+++ linux/arch/ia64/kernel/signal.c	2005-07-01 15:57:08.479428221 +1000
@@ -143,6 +143,7 @@ restore_sigcontext (struct sigcontext __
 
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
 		psr->mfh = 0;	/* drop signal handler's fph contents... */
+		preempt_disable();
 		if (psr->dfh)
 			ia64_drop_fpu(current);
 		else {
@@ -150,6 +151,7 @@ restore_sigcontext (struct sigcontext __
 			__ia64_load_fpu(current->thread.fph);
 			ia64_set_local_fpu_owner(current);
 		}
+		preempt_enable();
 	}
 	return err;
 }

