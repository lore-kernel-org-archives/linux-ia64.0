From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Jun 2004 15:34:22 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291532.i5TFWaY12681@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Tuesday, June 29, 2004 8:09 AM
> David Mosberger wrote on Friday, June 25, 2004 10:55 PM
> >  >> True, but it's really ugly to add more special cases.  Wouldn't it be
> >  >> better to explicitly pass the sp/bsp that need to be restored?
> >  >> (Caveat: can't use the normal calling conventions there; perhaps r17
> >  >> and r18 could be used?)
> >
> >  Ken> Yeah, but we have to update all the call sites, current efi_call_phys
> >  Ken> and two other PAL static/stacked calls.
> >
> > True, but I think there are only 3 call-sites.  If it turns out to be
> > _really_ ugly we can reonsider, but I think it might be a better
> > choice in the long run.
>
> How does this patch look?  It is a bit big. But what it does is really
> simple: change 3 call sites to save/restore virtual address of sp and
> ar.bsp/ar.bspstore.


To follow up the other bug in head.S, here is the fix.

---------
For BP, we are not installing any region 7 DTLB mapping for init_task.
However, kr(stack) is being initialized to a legal kernel granule that
the kernel resides.  If the first task context switch out of this
init_task happens to have its task struct in that very same granule,
the stack will not be mapped by any DTLB.  Patch to properly initialize
kr(stack) for BP.

=== arch/ia64/kernel/head.S 1.25 vs edited ==--- 1.25/arch/ia64/kernel/head.S	Mon Jun 28 22:07:49 2004
+++ edited/arch/ia64/kernel/head.S	Mon Jun 28 22:11:32 2004
@@ -154,8 +154,7 @@
 #endif
 	;;
 	tpa r3=r2		// r3 = phys addr of task struct
-	;;
-	shr.u r16=r3,IA64_GRANULE_SHIFT
+	mov r16=-1
 (isBP)	br.cond.dpnt .load_current // BP stack is on region 5 --- no need to map it

 	// load mapping for stack (virtaddr in r2, physaddr in r3)
@@ -169,6 +168,7 @@
 	dep r2=-1,r3,61,3	// IMVA of task
 	;;
 	mov r17=rr[r2]
+	shr.u r16=r3,IA64_GRANULE_SHIFT
 	;;
 	dep r17=0,r17,8,24
 	;;


