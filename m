From: Alexander Nyberg <alexn@dsv.su.se>
Date: Sun, 20 Feb 2005 10:38:42 +0000
Subject: Re: [PATCH] Errenous use of memset and memcpy
Message-Id: <1108895922.2272.1.camel@boxen>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108848352.682.2.camel@boxen>
In-Reply-To: <1108848352.682.2.camel@boxen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That should be copy_from_user, and the error checking needs to stay.
> 

Makes sense, thanks.

=== arch/ia64/ia32/ia32_signal.c 1.35 vs edited ==--- 1.35/arch/ia64/ia32/ia32_signal.c	2005-01-25 21:23:45 +01:00
+++ edited/arch/ia64/ia32/ia32_signal.c	2005-02-20 11:32:55 +01:00
@@ -460,9 +460,9 @@ __ia32_rt_sigsuspend (compat_sigset_t *s
 	sigset_t oldset, set;
 
 	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
-	memset(&set, 0, sizeof(&set));
+	memset(&set, 0, sizeof(sigset_t));
 
-	if (memcpy(&set.sig, &sset->sig, sigsetsize))
+	if (copy_from_user(&set.sig, &sset->sig, sigsetsize))
 		return -EFAULT;
 
 	sigdelsetmask(&set, ~_BLOCKABLE);



