From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 25 Jun 2004 16:31:15 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406251629.i5PGTmY30243@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Chen, Kenneth W wrote on Thursday, June 24, 2004 5:37 PM
> The regression is coming from moving init_task from region 7 to region
> 5.  The hang was a nested fault with no valid dtlb mapping for the init
> task's stack.  The problem was from physical mode efi call.  efi_call_phys
> does: ia64_switch_mode_phys, call the function, then ia64_switch_mode_virt.
> The ia64_switch_mode_virt now need to special case the init task to put
> sp and ar.bspstore into region5 instead of region7.  I have a quick patch
> that fix the hang.  Let me polish it a bit more and then post.
>
> Oh yeah, baby, the first two hunk in head.S is just plain wrong in this
> patch: http://www.gelato.unsw.edu.au/linux-ia64/0406/10047.html.  Let me
> work on that too .....

Regarding to rev 1.24 in head.S:
http://lia64.bkbits.net:8080/linux-ia64-2.5/diffs/arch/ia64/kernel/head.S@1.24?nav=index.html|src/.|src/arch|src/arch/ia64|src/arch/
ia64/kernel|hist/arch/ia64/kernel/head.S

The relocation of r16 is incorrect.  For BP, we are not installing any
region 7 TLB mapping.  But this patch will put a valid kernel granule
index into kr(stack).  Equivalently, it lies to the rest of the kernel
that it installed an entry at the index kernel image locates.  If the
first task coming out of this init_task happens to have its task struct
in that very same granule, the stack will not be mapped by any DTLB.
Then bad things happen like random hang because of nested fault.

The first two hunks in the following patch reverse that relocation. The
next two hunks fix the random hang observed when moving init_task from
region 7 to region 5.  As explained earlier, BP did a call to efi_call_phys
which switches to physical mode and then back to virtual.  When going
back to virtual, it converts ar.bspstore and sp to region 7 address.
After that, any heavy weight fault will lead into nested fault because
there are no region 7 dtlb mapping for its stack.  The fix is to special
case ia64_switch_mode_virt to compute ar.bspstore and sp's virtual
addresses into region 5.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


Tested on Intel tiger machine with several hundred consecutive boots.



--- 1.24/arch/ia64/kernel/head.S	Wed Jun 16 18:09:33 2004
+++ edited/arch/ia64/kernel/head.S	Fri Jun 25 08:26:19 2004
@@ -154,10 +154,9 @@ start_ap:
 #endif
 	;;
 	tpa r3=r2		// r3 = phys addr of task struct
+	mov r16=-1
+(isBP)	br.cond.dpnt .load_current // no need to map region 5 init_task
 	;;
-	shr.u r16=r3,IA64_GRANULE_SHIFT
-(isBP)	br.cond.dpnt .load_current // BP stack is on region 5 --- no need to map it
-
 	// load mapping for stack (virtaddr in r2, physaddr in r3)
 	rsm psr.ic
 	movl r17=PAGE_KERNEL
@@ -169,6 +168,7 @@ start_ap:
 	dep r2=-1,r3,61,3	// IMVA of task
 	;;
 	mov r17=rr[r2]
+	shr.u r16=r3,IA64_GRANULE_SHIFT
 	;;
 	dep r17=0,r17,8,24
 	;;
@@ -766,7 +766,9 @@ GLOBAL_ENTRY(ia64_switch_mode_virt)
 	flushrs				// must be first insn in group
 	srlz.i
  }
+	movl r19=init_task
 	;;
+	cmp.eq p7,p6=r19,r13		// special case init_task
 	mov cr.ipsr=r16			// set new PSR
 	add r3-ia64_switch_mode_virt,r15

@@ -781,11 +783,15 @@ GLOBAL_ENTRY(ia64_switch_mode_virt)
 	movl r18=KERNEL_START
 	dep r3=0,r3,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
 	dep r14=0,r14,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
-	dep r17=-1,r17,61,3
-	dep sp=-1,sp,61,3
+(p6)	dep r17=-1,r17,61,3
+(p6)	dep sp=-1,sp,61,3
+(p7)	dep r17=0,r17,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
+(p7)	dep sp =0, sp,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
 	;;
 	or r3=r3,r18
 	or r14=r14,r18
+(p7)	or r17=r17,r18
+(p7)	or sp=sp,r18
 	;;

 	mov r18=ar.rnat			// save ar.rnat



