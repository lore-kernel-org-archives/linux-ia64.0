From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 27 Oct 2009 10:52:23 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LRH.2.00.0910271150100.25075@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org>
In-Reply-To: <4ADD48D1.1040701@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, 20 Oct 2009, Tejun Heo wrote:

> > How about this one? (untested)
> > 
> > From: Jiri Kosina <jkosina@suse.cz>
> > Subject: sched: move rq_weight data array out of .percpu
> > 
> > Commit 34d76c41 introduced percpu array update_shares_data, size of which 
> > being proportional to NR_CPUS. Unfortunately this blows up ia64 for large 
> > NR_CPUS configuration, as ia64 allows only 64k for .percpu section.
> > 
> > Fix this by allocating this array dynamically and keep only pointer to it 
> > percpu.
> 
> If the structure can be dynamically allocated at all, just using
> percpu_alloc() to allocate the whole thing should solve it with the
> correct numa locality.

Unfortunately it's not that straightforward and easy, as we can't simply 
call __alloc_percpu from sched_init().

The reason is that does spin_unlock_irq(), and in sched_init() time it's 
too early for that, so we end up with

WARNING: at kernel/lockdep.c:2311 trace_hardirqs_on_caller+0xd2/0x1a0()
Hardware name: Kfisher   HT2100 HT1000
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.32-rc5-default #66
Call Trace:
 [<ffffffff81086a62>] ? trace_hardirqs_on_caller+0xd2/0x1a0
 [<ffffffff81054528>] warn_slowpath_common+0x78/0xd0
 [<ffffffff81356b8b>] ? _spin_unlock_irq+0x2b/0x40
 [<ffffffff8105458f>] warn_slowpath_null+0xf/0x20
 [<ffffffff81086a62>] trace_hardirqs_on_caller+0xd2/0x1a0
 [<ffffffff81086b3d>] trace_hardirqs_on+0xd/0x10
 [<ffffffff81356b8b>] _spin_unlock_irq+0x2b/0x40
 [<ffffffff811154c1>] pcpu_extend_area_map+0x41/0x110
 [<ffffffff81115ce0>] pcpu_alloc+0x120/0x890
 [<ffffffff81084577>] ? trace_hardirqs_off_caller+0x67/0xa0
 [<ffffffff8108578d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff8111646b>] __alloc_percpu+0xb/0x10
 [<ffffffff81712215>] sched_init+0x147/0x5d2
 [<ffffffff816fabca>] start_kernel+0x1fc/0x40c
 [<ffffffff816fa299>] x86_64_start_reservations+0x99/0xb9
 [<ffffffff816fa3bf>] x86_64_start_kernel+0x106/0x121
 [<ffffffff816fa140>] ? early_idt_handler+0x0/0x71
---[ end trace 4eaa2a86a8e2da22 ]---
start_kernel(): bug: interrupts were enabled *very* early, fixing it

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

