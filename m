From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 19 Nov 2007 05:17:43 +0000
Subject: Re: [PATCH 1/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <47411C77.8080108@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BDC7.1070702@jp.fujitsu.com>
In-Reply-To: <4714BDC7.1070702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon Horman wrote:
> When I apply this patch and enable VIRT_CPU_ACCOUNTING I get
> the following build error. Perhaps the fragment that creates
> account_process_tick in arch/ia64/kernel/time.c is missing?
> 
> kernel/built-in.o: In function `update_process_times': undefined
> reference to `account_process_tick'

I found that this error is caused by change of update_process_times,
i.e. the following commit.
Since my patches are based on 2.6.23, they should be rebased on
2.6.24-rcX and have some fixes.

> commit fa13a5a1f25f671d084d8884be96fc48d9b68275
> Author: Paul Mackerras <paulus@samba.org>
> Date:   Fri Nov 9 22:39:38 2007 +0100
> 
>     sched: restore deterministic CPU accounting on powerpc
> 
>     Since powerpc started using CONFIG_GENERIC_CLOCKEVENTS, the
>     deterministic CPU accounting (CONFIG_VIRT_CPU_ACCOUNTING) has been
>     broken on powerpc, because we end up counting user time twice: once in
>     timer_interrupt() and once in update_process_times().
> 
>     This fixes the problem by pulling the code in update_process_times
>     that updates utime and stime into a separate function called
>     account_process_tick.  If CONFIG_VIRT_CPU_ACCOUNTING is not defined,
>     there is a version of account_process_tick in kernel/timer.c that
>     simply accounts a whole tick to either utime or stime as before.  If
>     CONFIG_VIRT_CPU_ACCOUNTING is defined, then arch code gets to
>     implement account_process_tick.
> 
>     This also lets us simplify the s390 code a bit; it means that the s390
>     timer interrupt can now call update_process_times even when
>     CONFIG_VIRT_CPU_ACCOUNTING is turned on, and can just implement a
>     suitable account_process_tick().
> 
>     account_process_tick() now takes the task_struct * as an argument.
>     Tested both with and without CONFIG_VIRT_CPU_ACCOUNTING.
> 
>     Signed-off-by: Paul Mackerras <paulus@samba.org>
>     Signed-off-by: Ingo Molnar <mingo@elte.hu>

Thanks,
H.Seto
