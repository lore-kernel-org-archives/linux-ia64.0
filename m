From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 02 Jun 2005 19:43:59 +0000
Subject: fsys_rt_sigprocmask fastcall missing PF_FREEZE handling?
Message-Id: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just compared fsys_rt_sigprocmask in arch/ia64/kernel/fsys.S with 
kernel/signal.c and noted that there does not seem to be any handling of 
the PF_FREEZE flag. This may be okay if IA64 does not support power 
management but I see some adaptec drivers in SLES9 that use PF_FREEZE.

c:

fastcall void recalc_sigpending_tsk(struct task_struct *t)
{
        if (t->signal->group_stop_count > 0 ||
            (t->flags & PF_FREEZE) ||
            PENDING(&t->pending, &t->blocked) ||
            PENDING(&t->signal->shared_pending, &t->blocked))
                set_tsk_thread_flag(t, TIF_SIGPENDING);
        else
                clear_tsk_thread_flag(t, TIF_SIGPENDING);
}

asm:
        ld4 r17=[r17]           // r17 <- current->signal->group_stop_count
(p7)    mov r8=0                // clear error code

        ld8 r19=[r19]           // r19 <- current->signal->shared_pending
        ;;
        cmp4.gt p6,p7=r17,r0    // p6/p7 <- (current->signal->group_stop_count > 0)?
(p8)    mov r8=0                // clear error code

        or r18=r18,r19          // r18 <- current->pending | current->signal->shared_pending
        ;;
        // r18 <- (current->pending | current->signal->shared_pending) & ~current->blocked:
        andcm r18=r18,r14
        add r9=TI_FLAGS+IA64_TASK_SIZE,r16
        ;;

(p7)    cmp.ne.or.andcm p6,p7=r18,r0            // p6/p7 <- signal pending
        mov r19=0                                       // i must not leak kernel bits...
(p6)    br.cond.dpnt.many .sig_pending
        ;;

1:      ld4 r17=[r9]                            // r17 <- current->thread_info->flags
        ;;
        mov ar.ccv=r17
        and r18=~_TIF_SIGPENDING,r17            // r18 <- r17 & ~(1 << TIF_SIGPENDING)
        ;;

        st8 [r2]=r14                            // update current->blocked with new mask
        cmpxchg4.acq r14=[r9],r18,ar.ccv        // current->thread_info->flags <- r18
        ;;
        cmp.ne p6,p0=r17,r14                    // update failed?
(p6)    br.cond.spnt.few 1b                     // yes -> retry

