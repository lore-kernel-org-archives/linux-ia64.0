From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 22 Nov 2006 19:23:52 +0000
Subject: RE: [PATCH] - Reduce overhead of FP exception logging messages
Message-Id: <000001c70e6b$be9fed30$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote on Wednesday, November 22, 2006 7:55 AM
> Improve the scalability of the fpswa code that rate-limits
> logging of messages.
> 
> There are 2 distinctly different problems in this code.
> 
> 1) If prctl is used to disable logging, last_time is never
>    updated. The result is that fpu_swa_count is zeroed out on
>    EVERY fp fault. This causes a very very hot cache line.
>    The fix reduces the wallclock time of a 1024p FP exception test
>    from 28734 sec to 19 sec!!!
> 
> 2) On VERY large systems, excessive messages are logged because
>    multiple cpus can each reset or increment fpu_swa_count at
>    about the same time. The result is that hundreds of messages
>    are logged each second. The fixes reduces the logging rate
>    to ~1 per second.
> 
> 
> +static DEFINE_PER_CPU(struct fpu_swa_msg, cpulast);
> +DECLARE_PER_CPU(struct fpu_swa_msg, cpulast);
> +static struct fpu_swa_msg last __cacheline_aligned;
> 
> [...]
> 
> +	if (!(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT))  {
> +		unsigned long count, current_jiffies = jiffies;
> +		struct fpu_swa_msg *cp = &__get_cpu_var(cpulast);


Now that you fixed prctl problem mentioned in (1) above, do you really
have to go such elaborated per-cpu method of updating last_time and
fpu_swa_count?  fpu_swa_count should really be declared as atomic_t and
use atomic_inc() for updates.  And I would think that should rate limit
properly at 5 per 5 sec.

- Ken
