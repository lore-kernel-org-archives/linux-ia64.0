From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 09 Dec 2003 21:54:01 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107100743218765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

On Mon, Dec 08, 2003 at 05:57:04PM -0800, Stephane Eranian wrote:
> 
> Yes, clearly you do not want to preempt in the perfmon interrupt handler.
> I think we need to also make sure we do not preempt during the perfmonctl()
> system call, at least until we verify that there is no assumptions in there.
> Similarly in all the VFS entry points, such as pfm_close(). I will try
> and see what I can do before the end of the week.
> 
I checked the code and I believe we are covered because we rely upon
spin_lock_irqsave/restore for most entry points into perfmon-2. That
is enough to block/unblock preemption in all the calls that need it.
That applies to the sys_perfmonctl() entry, the VFS entry points
as well as the internal entry points for copy_threads() and a few others.
The only one missing is the one you found. The PMU state save/restore
are called from the scheduler and are therefore protected as well.

Thanks for tracking down that one bug.

-- 

-Stephane
