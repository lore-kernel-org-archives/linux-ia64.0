From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 22 Aug 2001 16:49:57 +0000
Subject: [Linux-ia64] [patch] fix for fph corner case
Message-Id: <marc-linux-ia64-105590698805096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Attached is a small patch that fixes an SMP corner case where the fph
(register f32-f127) could get corrupted during signal handling.  The
sequence of events that led to the corruption is as follows:

	- program uses f32-f127 and then gets interrupted by a signal
	- signal handler executes and then returns
	- on the way back to user-level, the CPU decides it's time for
	  a context switch
	- the context switch sees that psr.mfh is set and saves the
	  fph partition, thus overwriting the old state with the
	  register contents from the signal handler

This bug affects SMP only, UP should be fine.

Thanks to Asit for finding and fixing this.

	--david

--- lia64/arch/ia64/kernel/signal.c	Wed Apr 11 14:21:32 2001
+++ lia64-kdb/arch/ia64/kernel/signal.c	Tue Aug 21 18:23:50 2001
@@ -139,10 +139,9 @@
 		struct ia64_psr *psr = ia64_psr(&scr->pt);
 
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
-		if (!psr->dfh) {
-			psr->mfh = 0;
+		psr->mfh = 0;	/* drop signal handler's fph contents... */
+		if (!psr->dfh)
 			__ia64_load_fpu(current->thread.fph);
-		}
 	}
 	return err;
 }

