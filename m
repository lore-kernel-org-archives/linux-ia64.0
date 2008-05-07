From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 07 May 2008 08:54:50 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1210150490.23336.7.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2008-05-07 at 08:59 +0200, Petr Tesarik wrote:
> On Wed, 2008-05-07 at 09:57 +0900, Hidetoshi Seto wrote:
> > Hi all,
> > 
> > Luck, Tony wrote:
> > >> So it's definitely in mainline, and its definitely
> > >> not Seto-san's patch.
> > > 
> > > Here's the root of the problem (arch/ia64/kernel/entry.S):
> > > 
> > Please see:
> > 
> >     841 GLOBAL_ENTRY(ia64_leave_kernel)
> >     842         PT_REGS_UNWIND_INFO(0)
> >     843         /*
> >     844          * work.need_resched etc. mustn't get changed by this CPU before it returns to
> >     845          * user- or fsys-mode, hence we disable interrupts early on.
> >     846          *
> >     847          * p6 controls whether current_thread_info()->flags needs to be check for
> >     848          * extra work.  We always check for extra work when returning to user-level.
> >     849          * With CONFIG_PREEMPT, we also check for extra work when the preempt_count
> >     850          * is 0.  After extra work processing has been completed, execution
> >     851          * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-check
> >     852          * needs to be redone.
> >     853          */
> >     854 #ifdef CONFIG_PREEMPT
> >     855         rsm psr.i                               // disable interrupts
> >     856         cmp.eq p0,pLvSys=r0,r0                  // pLvSys=0: leave from
> >     856 kernel
> >     857 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
> >     858         ;;
> >     859         .pred.rel.mutex pUStk,pKStk
> >     860 (pKStk) ld4 r21=[r20]                   // r21 <- preempt_count
> >     861 (pUStk) mov r21=0                       // r21 <- 0
> >     862         ;;
> >     863         cmp.eq p6,p0=r21,r0             // p6 <- pUStk || (preempt_count
> >     863  = 0)
> >     864 #else
> >     865 (pUStk) rsm psr.i
> >     866         cmp.eq p0,pLvSys=r0,r0          // pLvSys=0: leave from kernel
> >     867 (pUStk) cmp.eq.unc p6,p0=r0,r0          // p6 <- pUStk
> >     868 #endif
> >     869 .work_processed_kernel:
> >     870         adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
> >     871         ;;
> >     872 (p6)    ld4 r31=[r17]                           // load current_thread_i
> >     872 nfo()->flags
> >     873         adds r21=PT(PR)+16,r12
> >     874         ;;
> >     875
> >     876         lfetch [r21],PT(CR_IPSR)-PT(PR)
> >     877         adds r2=PT(B6)+16,r12
> >     878         adds r3=PT(R16)+16,r12
> >     879         ;;
> >     880         lfetch [r21]
> >     881         ld8 r28=[r2],8          // load b6
> >     882         adds r29=PT(R24)+16,r12
> >     883
> >     884         ld8.fill r16=[r3],PT(AR_CSD)-PT(R16)
> >     885         adds r30=PT(AR_CCV)+16,r12
> >     886 (p6)    and r19=TIF_WORK_MASK,r31               // any work other than T
> >     886 IF_SYSCALL_TRACE?
> >     887         ;;
> >     888         ld8.fill r24=[r29]
> >     889         ld8 r15=[r30]           // load ar.ccv
> >     890 (p6)    cmp4.ne.unc p6,p0=r19, r0               // any special work pend
> >     890 ing?
> >     891         ;;
> >     892         ld8 r29=[r2],16         // load b7
> >     893         ld8 r30=[r3],16         // load ar.csd
> >     894 (p6)    br.cond.spnt .work_pending
> > 
> > and:
> > 
> >    1160 .work_pending_syscall:
> >    1161         add r2=-8,r2
> >    1162         add r3=-8,r3
> >    1163         ;;
> >    1164         st8 [r2]=r8
> >    1165         st8 [r3]=r10
> >    1166 .work_pending:
> >    1167         tbit.z p6,p0=r31,TIF_NEED_RESCHED               // current_thread_info()->need_resched=0?
> >    1168 (p6)    br.cond.sptk.few .notify
> >    1169 #ifdef CONFIG_PREEMPT
> >    1170 (pKStk) dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
> >    1171         ;;
> >    1172 (pKStk) st4 [r20]=r21
> >    1173         ssm psr.i               // enable interrupts
> >    1174 #endif
> > >    1175         br.call.spnt.many rp=schedule
> > >    1176 .ret9:  cmp.eq p6,p0=r0,r0                              // p6 <- 1
> > >    1177         rsm psr.i               // disable interrupts
> > >    1178         ;;
> > >    1179 #ifdef CONFIG_PREEMPT
> > >    1180 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
> > >    1181         ;;
> > >    1182 (pKStk) st4 [r20]=r0            // preempt_count() <- 0
> > >    1183 #endif
> > >    1184 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
> > >    1185         br.cond.sptk.many .work_processed_kernel        // re-check
> > >    1186 
> > >    1187 .notify:
> > >    1188 (pUStk) br.call.spnt.many rp=notify_resume_user
> > > 
> > > on line 1188 we call notify_resume_user() with interrupts disabled (at
> > > least if we fall through from the code above ... I didn't check the
> > > state of interrupts if we branch to ".notify").
> > 
> > AFAIK, we always call notify_resume_user() with interrupts disabled.
> > Is this right?
> > 
> > > So we start down this call chain to the might_sleep() check:
> > > 
> > >  [<a000000100011bf0>] show_stack+0x50/0xa0
> > >  [<a000000100011c70>] dump_stack+0x30/0x60
> > >  [<a000000100061a90>] __might_sleep+0x1f0/0x220
> > >  [<a000000100709020>] down_read+0x20/0x60
> > >  [<a0000001000fe060>] access_process_vm+0x60/0x2c0
> > >  [<a00000010002a280>] ia64_sync_kernel_rbs+0x40/0x100
> > >  [<a00000010002a400>] do_sync_rbs+0xc0/0x100
> > >  [<a00000010000ac30>] unw_init_running+0x70/0xa0
> > >  [<a00000010002a5c0>] ia64_sync_krbs+0x80/0xa0
> > >  [<a000000100012690>] do_notify_resume_user+0x110/0x140
> > >  [<a00000010000aac0>] notify_resume_user+0x40/0x60
> > >  [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
> > >  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
> > 
> > So, I think the problem is not "why interrupts are disabled," but
> > "why sleep in this path which always with interrupts disabled."
> > 
> > It obviously means ia64_sync_kernel_rbs should care about that.
> > The function was introduced by the following commit:
> > 
> > > commit 3b2ce0b17824c42bc2e46f7dd903b4acf5e9fff9
> > > Author: Petr Tesarik <ptesarik@suse.cz>
> > > Date:   Wed Dec 12 15:23:34 2007 +0100
> > >
> > >     [IA64] Synchronize kernel RSE to user-space and back
> > 
> > Hmm, could you make ia64_sync_kernel_rbs to safe with interrupts
> > disabled, Petr?
> 
> No, the point of that function is to copy part of the kernel RBS to user
> RBS. Accesses to user space are always allowed to sleep and there's
> nothing I can do about it (without rewriting the whole memory management
> in Linux from scratch). All I can do is to take the simpler approach
> without TIF_RESTORE_RSE I proposed in the very beginning of the RSE sync
> discussion, but which was then turned down, because Roland warned about
> possible severe performance degradations.
> 
> The introduction of TIF_RESTORE_RSE was originally Shaohua's idea, so
> maybe he knows how to do it properly.
> 
> BTW why must be interrupts disabled in this path? Would it be possible
> to re-enable them for the duration of the synchronization, or does it
> harm somehow?
No idea how to fix it. i have the same question why
do_notify_resume_user in called with interrupt disabled.
do_notify_resume_user->ia64_do_signal->get_signal_to_deliver which could
sleep (like try_to_freeze) and this routine calls
spin_lock_irq()/spin_unlock_irq(), this will enable interrupt.

Thanks,
Shaohua

