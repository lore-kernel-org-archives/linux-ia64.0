From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 17 Apr 2008 01:32:03 +0000
Subject: Re: [PATCH] ia64: disable interrupts on exit of ia64_trace_syscall
Message-Id: <4806A893.2070009@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4805B747.5030605@jp.fujitsu.com>
In-Reply-To: <4805B747.5030605@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(resend since i missed to configure name in Signed-off-by line)

While testing with CONFIG_VIRT_CPU_ACCOUNTING=y, I found that
I occasionally get very huge system time in some threads.

So I dug the issue and finally noticed that it was caused
because of an interrupt which interrupt in the following window:

> > [arch/ia64/kernel/entry.S: (!CONFIG_PREEMPT && CONFIG_VIRT_CPU_ACCOUNTING)]
> >
> > ENTRY(ia64_leave_syscall)
> >    :
> > (pUStk) rsm psr.i
> >         cmp.eq pLvSys,p0=r0,r0          // pLvSys=1: leave from syscall
> > (pUStk) cmp.eq.unc p6,p0=r0,r0          // p6 <- pUStk
> > .work_processed_syscall:
> >         adds r2=PT(LOADRS)+16,r12
> > (pUStk) mov.m r22=ar.itc                        // fetch time at leave
> >         adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
> >         ;;
> > <<< window: from here >>>
> > (p6)    ld4 r31=[r18]  // load current_thread_info()->flags
> >         ld8 r19=[r2],PT(B6)-PT(LOADRS)
> >         adds r3=PT(AR_BSPSTORE)+16,r12
> >         ;;
> >         mov r16=ar.bsp
> >         ld8 r18=[r2],PT(R9)-PT(B6)
> > (p6)    and r15=TIF_WORK_MASK,r31  // any work other than TIF_SYSCALL_TRACE?
> >         ;;
> >         ld8 r23=[r3],PT(R11)-PT(AR_BSPSTORE)
> > (p6)    cmp4.ne.unc p6,p0=r15, r0               // any special work pending?
> > (p6)    br.cond.spnt .work_pending_syscall
> >         ;;
> >         ld8 r9=[r2],PT(CR_IPSR)-PT(R9)
> >         ld8 r11=[r3],PT(CR_IIP)-PT(R11)
> > (pNonSys) break 0 // bug check: we shouldn't be here if pNonSys is TRUE!
> >         ;;
> >         invala
> > <<< window: to here >>>
> >         rsm psr.i | psr.ic // turn off interrupts and interruption collection

If pUStk is true, it means we are going to return user mode, hence we fetch
ar.itc to get time at leave from system.
It seems that it is not possible to interrupt the window if pUStk is true,
because interrupts are disabled early.  And also disabling interrupt makes
sense because it is safe for referring current_thread_info()->flags.

However interrupting the window while pUStk is true was possible.
The route was:
  ia64_trace_syscall
   -> .work_pending_syscall_end
    -> .work_processed_syscall
Only in case entering the window from this route, interrupts are enabled
during in the window even if pUStk is true.  I suppose interrupts must be
disabled here anyway if pUStk is true.
I'm not sure but afraid that what kind of bad effect were there, other
than crazy system time which I found.

FYI, there was a commit 6f6d75825dc49b082906b84537b4df28293c2977 that
points out a bug at same point(exit of ia64_trace_syscall) in 2006.
It can be said that there was an another bug.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/entry.S |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 3c331c4..0f6965a 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -570,6 +570,7 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 	br.call.sptk.many rp=syscall_trace_leave // give parent a chance to catch return value
 .ret3:
 (pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
+(pUStk)	rsm psr.i				// disable interrupts
 	br.cond.sptk .work_pending_syscall_end

 strace_error:
