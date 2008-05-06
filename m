From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 May 2008 21:41:08 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC0147BD93@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So it's definitely in mainline, and its definitely
> not Seto-san's patch.

Here's the root of the problem (arch/ia64/kernel/entry.S):

   1175         br.call.spnt.many rp=schedule
   1176 .ret9:  cmp.eq p6,p0=r0,r0                              // p6 <- 1
   1177         rsm psr.i               // disable interrupts
   1178         ;;
   1179 #ifdef CONFIG_PREEMPT
   1180 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
   1181         ;;
   1182 (pKStk) st4 [r20]=r0            // preempt_count() <- 0
   1183 #endif
   1184 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
   1185         br.cond.sptk.many .work_processed_kernel        // re-check
   1186 
   1187 .notify:
   1188 (pUStk) br.call.spnt.many rp=notify_resume_user

on line 1188 we call notify_resume_user() with interrupts disabled (at
least if we fall through from the code above ... I didn't check the
state of interrupts if we branch to ".notify").

So we start down this call chain to the might_sleep() check:

 [<a000000100011bf0>] show_stack+0x50/0xa0
 [<a000000100011c70>] dump_stack+0x30/0x60
 [<a000000100061a90>] __might_sleep+0x1f0/0x220
 [<a000000100709020>] down_read+0x20/0x60
 [<a0000001000fe060>] access_process_vm+0x60/0x2c0
 [<a00000010002a280>] ia64_sync_kernel_rbs+0x40/0x100
 [<a00000010002a400>] do_sync_rbs+0xc0/0x100
 [<a00000010000ac30>] unw_init_running+0x70/0xa0
 [<a00000010002a5c0>] ia64_sync_krbs+0x80/0xa0
 [<a000000100012690>] do_notify_resume_user+0x110/0x140
 [<a00000010000aac0>] notify_resume_user+0x40/0x60
 [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
 [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
