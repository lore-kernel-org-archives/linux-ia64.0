From: "Fleckenstein, Chuck" <chuck.fleckenstein@intel.com>
Date: Wed, 06 Mar 2002 20:59:32 +0000
Subject: RE: [Linux-ia64] psr.dt state when DO_SAVE_MIN is invoked
Message-Id: <marc-linux-ia64-105590701905234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905232@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


not sure if this is the same problem you are seeing, but
with earlier kernels we were seeing a recursive fault and tracked it down
to an old serialization bug (has since been fixed via code rewrite in new
kernels)..

the problem was a serialization issue in ia64_switch_to (entry.S) and it was
due to a 
load of the stack pointer that could be done before the insertion for the
new mapping was
completed...  we just moved the load down below the ic serialization to make
sure
the insertion was completed before trying to do the access..
The itr.d is located at the bottom of the switch_to routine and then
immediately
branched to .done...

not sure if this the same issue you are encountering..

my 0.5 cents worth for today...

Chuck

###############  diffs between non faulting and faulting kernels...

Index: entry.S
=================================RCS file: /ehome/cvs/CVSROOT/linux.sv/arch/ia64/kernel/entry.S,v
retrieving revision 1.13
retrieving revision 1.12
diff -c -r1.13 -r1.12
*** entry.S	2002/01/07 23:36:43	1.13
--- entry.S	2001/12/05 00:16:07	1.12
***************
*** 153,163 ****
  (p6)	cmp.eq p7,p6=r26,r27
  (p6)	br.cond.dpnt.few .map
  	;;
! .done:
  (p6)	ssm psr.ic			// if we we had to map, renable the
psr.ic bit FIRST!!!
  	;;
  (p6)	srlz.d
- 	ld8 sp=[r21]			// load kernel stack pointer of new
task
  	mov IA64_KR(CURRENT)=r20	// update "current" application
register
  	mov r8=r13			// return pointer to previously
running task
  	mov r13=in0			// set "current" pointer
--- 153,162 ----
  (p6)	cmp.eq p7,p6=r26,r27
  (p6)	br.cond.dpnt.few .map
  	;;
! .done:	ld8 sp=[r21]			// load kernel stack pointer
of new task
  (p6)	ssm psr.ic			// if we we had to map, renable the
psr.ic bit FIRST!!!
  	;;
  (p6)	srlz.d
  	mov IA64_KR(CURRENT)=r20	// update "current" application
register
  	mov r8=r13			// return pointer to previously
running task
  	mov r13=in0			// set "current" pointer

> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com]
> Sent: Wednesday, March 06, 2002 11:46 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] psr.dt state when DO_SAVE_MIN is invoked
> 
> 
> Some systems running an old kernel (2.4.7) have been seen to
> hang looping in an apparent recursive TLB fault.  The same tests
> that locked up these machines seem to run fine on new kernels,
> but while looking into the issue the following oddity was
> noted in the code, that still exists in 2.4.18
> 
> in arch/ia64/kernel/ivt.S we have:
> ENTRY(page_fault)
>         ssm psr.dt
>         ;;
>         srlz.i
>         ;;
>         SAVE_MIN_WITH_COVER
> 
> and minstate.h defines:
> 
> #define SAVE_MIN_WITH_COVER     DO_SAVE_MIN(cover, mov rCRIFS=cr.ifs,)
> 
> which in turn says:
> 
> /*
>  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
>  * the minimum state necessary that allows us to turn psr.ic back
>  * on.
>  *
>  * Assumed state upon entry:
>  *      psr.ic: off
>  *      psr.dt: off
>  *      r31:    contains saved predicates (pr)
>  *
> 	...
> 
> See how page_fault explicitly sets psr.dt, and then invokes a macro
> that says that the assumed entry state is psr.dt should be off. Is
> the comment just plain wrong, or is there a potential issue here?
> 
> The 2.4.7 failure hits at around the 67 hour mark in the tests, the
> newer (RedHat 7.2 a.k.a. 2.4.9-18) kernel survives 72 hours ... but
> that's as long as we scheduled the test to run.
> 
> -Tony
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

