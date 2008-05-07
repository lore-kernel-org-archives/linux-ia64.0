From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 07 May 2008 09:05:59 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <482170F7.2050909@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oh, wait...

Petr Tesarik wrote:
> On Wed, 2008-05-07 at 09:57 +0900, Hidetoshi Seto wrote:
>>
>>    1160 .work_pending_syscall:
>>    1161         add r2=-8,r2
>>    1162         add r3=-8,r3
>>    1163         ;;
>>    1164         st8 [r2]=r8
>>    1165         st8 [r3]=r10
>>    1166 .work_pending:
>>    1167         tbit.z p6,p0=r31,TIF_NEED_RESCHED               // current_thread_info()->need_resched=0?
>>    1168 (p6)    br.cond.sptk.few .notify
>>    1169 #ifdef CONFIG_PREEMPT
>>    1170 (pKStk) dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
>>    1171         ;;
>>    1172 (pKStk) st4 [r20]=r21
>>    1173         ssm psr.i               // enable interrupts
>>    1174 #endif
>>>    1175         br.call.spnt.many rp=schedule
>>>    1176 .ret9:  cmp.eq p6,p0=r0,r0                              // p6 <- 1
>>>    1177         rsm psr.i               // disable interrupts
>>>    1178         ;;
>>>    1179 #ifdef CONFIG_PREEMPT
>>>    1180 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
>>>    1181         ;;
>>>    1182 (pKStk) st4 [r20]=r0            // preempt_count() <- 0
>>>    1183 #endif
>>>    1184 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
>>>    1185         br.cond.sptk.many .work_processed_kernel        // re-check
>>>    1186 
>>>    1187 .notify:
>>>    1188 (pUStk) br.call.spnt.many rp=notify_resume_user
>>>
>> AFAIK, we always call notify_resume_user() with interrupts disabled.
>> Is this right?

If I am right, this also means we always call schedule() with interrupts
disabled, when it is required without CONFIG_PREEMPT.

...Doesn't it matter, Tony?  I think it is quite strange.

>> Hmm, could you make ia64_sync_kernel_rbs to safe with interrupts
>> disabled, Petr?
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

Good point.
I'm not sure the reason, but I suppose we can call notify_resume_user()
and schedule() with interrupts enabled.  Possibly we must do so.

Thanks,
H.Seto
