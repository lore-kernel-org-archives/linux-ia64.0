From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 May 2004 00:17:32 +0000
Subject: Re: Error handling bug in fsys_rt_sigprocmask
Message-Id: <16555.63772.361093.311578@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeekplxvah.fsf@sykes.suse.de>
In-Reply-To: <jeekplxvah.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 May 2004 00:30:34 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> I did remove the second check.  But there is now an
  Andreas> additional bundle and I couldn't find any way to avoid
  Andreas> that.

I think I'm going to go with the attached patch --- unless you find
something wrong with it.

	--david

=== arch/ia64/kernel/fsys.S 1.24 vs edited ==--- 1.24/arch/ia64/kernel/fsys.S	Thu May  6 17:46:45 2004
+++ edited/arch/ia64/kernel/fsys.S	Wed May 19 16:32:39 2004
@@ -362,7 +362,7 @@
 	ld8 r31=[r31]				// r31 <- current->sighand
 #endif
 	and r9=TIF_ALLWORK_MASK,r9
-	tnat.nz p6,p0=r32
+	cmp4.ltu p6,p0=SIG_SETMASK,r32
 	;;
 	cmp.ne p7,p0=0,r9
 	tnat.nz.or p6,p0=r35
@@ -370,6 +370,7 @@
 	;;
 	cmp.ne p15,p0=r0,r34			// oset != NULL?
 	cmp.ne.or p6,p0=_NSIG_WORDS*8,r35
+	tnat.nz.or p6,p0=r32
 	tnat.nz.or p8,p0=r33
 
 (p6)	br.spnt.few .fail_einval		// fail with EINVAL
@@ -462,12 +463,10 @@
 	st4.rel [r31]=r0			// release the lock
 #endif
 	ssm psr.i
-	cmp.ne p9,p0=r8,r0			// check for bad HOW value
 	;;
 
 	srlz.d					// ensure psr.i is set again
 	mov r18=0					// i must not leak kernel bits...
-(p9)	br.spnt.few .fail_einval		// bail out for bad HOW value
 
 .store_mask:
 EX(.fail_efault, (p15) probe.w.fault r34, 3)	// verify user has write-access to *oset
