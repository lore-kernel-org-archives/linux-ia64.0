From: "Jim Hull" <jim.hull@hp.com>
Date: Wed, 07 Sep 2005 17:33:19 +0000
Subject: RE: [patch] delete sync.i in ia64_switch_to()
Message-Id: <200509071733.KAA18785@lucy.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070723.j877N9g25144@unix-os.sc.intel.com>
In-Reply-To: <200509070723.j877N9g25144@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That sync.i is not old code - it is required.

It is not there to handle kernel fc instructions - as you say, they have
their own sync instructions.  The sync.i in the context switch path is there
to guarantee that user-mode fc's become visible.

The case it's covering is one where some user app is modifying code using
the required sequence (as described on the sync instruction page in SDM
Volume 3), but in the midst of that sequence, it gets interrupted, context
switched, and rescheduled onto some other processor.  In that case, unless
the OS issues the sync.i on the app's behalf on the original processor, then
those fc's need not ever become visible.  The sync.i that the app
(eventually) does as part of it's sequence isn't good enough, because it
executes on the second processor, and syncs aren't broadcast between
processors.

Section 4.5.2.1 of SDM 2.1, Volume 2, Part II (page 2:428) talks about this
requirement.  That section also says that an mf instruction is required in
the context switch path.

Now I'm no expert on the linux codebase, so maybe these requirements are
being met by some other part of the context-switch path.  But if not, then
rather than a patch to delete the sync instruction, I think you need one to
improve the comments, and add the missing mf.

 -- Jim
    Itanium Processor Architect at HP 

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Chen, Kenneth W
> Sent: Wednesday, September 07, 2005 12:22 AM
> To: linux-ia64@vger.kernel.org
> Subject: [patch] delete sync.i in ia64_switch_to()
> 
> The sync.i instruction in ia64_switch_to() context switch code
> looks like an old leftover code.  sync.i instruction supposedly
> ensures flush cache operation issued by processor become visible
> to memory reference.  Everywhere I looked where fc instruction is
> used (ia64_fc), a sync.i is always accompanied.  Everywhere in
> the vicinity of context switch (save_switch_stack/load_switch_stack)
> don't have any fc instruction in there.  I don't see any reason why
> we need to issue sync.i in context switch code.  Patch to remove it.
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> 
> --- ./arch/ia64/kernel/entry.S.orig	2005-09-06 
> 22:36:17.114182129 -0700
> +++ ./arch/ia64/kernel/entry.S	2005-09-07 
> 00:20:37.216644505 -0700
> @@ -213,10 +213,6 @@ GLOBAL_ENTRY(ia64_switch_to)
>  	mov r13=in0			// set "current" pointer
>  	;;
>  	DO_LOAD_SWITCH_STACK
> -
> -#ifdef CONFIG_SMP
> -	sync.i				// ensure "fc"s done by 
> this CPU are visible on other CPUs
> -#endif
>  	br.ret.sptk.many rp		// boogie on out in new context
>  
>  .map:
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


