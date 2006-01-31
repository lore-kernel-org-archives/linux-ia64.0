From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 31 Jan 2006 17:44:51 +0000
Subject: Re: [patch 3/6] prefetch bottom of kernel rbs stack at syscall exit path
Message-Id: <ed5aea430601310944s6d15af57ude72f063502df671@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
In-Reply-To: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How much latency does this add for a minimal syscall when everything is cached?

  --david

On 1/31/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> Kernel knows where the register backing store is corresponding
> to user dirty stack registers.  Prefetch those cache lines as
> early as possible in ia64_leave_syscall path.
>
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>
>
> --- ./arch/ia64/kernel/entry.S.orig     2006-01-02 19:21:10.000000000 -0800
> +++ ./arch/ia64/kernel/entry.S  2006-01-30 13:26:41.161634409 -0800
> @@ -715,10 +715,11 @@ ENTRY(ia64_leave_syscall)
>         ;;
>  (p6)   ld4 r31=[r18]                           // load current_thread_info()->flags
>         ld8 r19=[r2],PT(B6)-PT(LOADRS)          // load ar.rsc value for "loadrs"
> -       nop.i 0
> +       add r17=IA64_RBS_OFFSET,r13
>         ;;
>         mov r16=ar.bsp                          // M2  get existing backing store pointer
>         ld8 r18=[r2],PT(R9)-PT(B6)              // load b6
> +       shr r22=r19,16
>  (p6)   and r15=TIF_WORK_MASK,r31               // any work other than TIF_SYSCALL_TRACE?
>         ;;
>         ld8 r23=[r3],PT(R11)-PT(AR_BSPSTORE)    // load ar.bspstore (may be garbage)
> @@ -729,6 +730,12 @@ ENTRY(ia64_leave_syscall)
>         ld8 r9=[r2],PT(CR_IPSR)-PT(R9)
>         ld8 r11=[r3],PT(CR_IIP)-PT(R11)
>  (pNonSys) break 0              //      bug check: we shouldn't be here if pNonSys is TRUE!
> +1:
> +(pUStk)        lfetch [r17],128
> +       add r22=-128,r22
> +       ;;
> +(pUStk)        cmp.gt.unc p7,p0=r22,r0
> +(p7)   br.dptk.few 1b
>         ;;
>         invala                  // M0|1 invalidate ALAT
>         rsm psr.i | psr.ic      // M2   turn off interrupts and interruption collection
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
