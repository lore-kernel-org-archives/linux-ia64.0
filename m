From: Alexander Nyberg <alexn@dsv.su.se>
Date: Sat, 19 Feb 2005 21:25:52 +0000
Subject: [PATCH] Errenous use of memset and memcpy
Message-Id: <1108848352.682.2.camel@boxen>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I stumbled across this, looks weird. Presumable fix is:

=== arch/ia64/ia32/ia32_signal.c 1.35 vs edited ==--- 1.35/arch/ia64/ia32/ia32_signal.c	2005-01-25 21:23:45 +01:00
+++ edited/arch/ia64/ia32/ia32_signal.c	2005-02-12 13:12:25 +01:00
@@ -460,10 +460,9 @@ __ia32_rt_sigsuspend (compat_sigset_t *s
 	sigset_t oldset, set;
 
 	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
-	memset(&set, 0, sizeof(&set));
+	memset(&set, 0, sizeof(sigset_t));
 
-	if (memcpy(&set.sig, &sset->sig, sigsetsize))
-		return -EFAULT;
+	memcpy(&set.sig, &sset->sig, sigsetsize);
 
 	sigdelsetmask(&set, ~_BLOCKABLE);
 


