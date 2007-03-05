From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 05 Mar 2007 20:05:23 +0000
Subject: Re: debug registers and fork
Message-Id: <20070305200523.GB9468@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070226235154.GB19630@frankl.hpl.hp.com> <200703051825.16473.ak@suse.de>
In-Reply-To: <200703051825.16473.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com

Andi,

On Mon, Mar 05, 2007 at 06:25:16PM +0100, Andi Kleen wrote:
> On Tuesday 27 February 2007 00:51, Stephane Eranian wrote:
> > 
> > I have come across an issue with a monitoring using the
> > hardware debug registers on ia64/i386/x86-64.
> > 
> > It seems that the way debug registers are inherited across fork
> > differs between ia-64 and i386/x86-64. On ia-64, the debug registers
> > are NEVER inherited in the child. The copy_thread() routine clears
> > the necessary thread flags to avoid reloading the debug registers in
> > the child.
> > 
> > Now, on x86-64, it appears that the TIF_DEBUG flag is inherited via
> > setup_thread_stack(). By virtue of dup_task_struct() the debug registers
> > get copied into the child task on fork. So the child has active breakpoints,
> > unless I am mistaken somewhere.
> > 
> > Given the way the ptrace() interface works, I would tend to
> > think that the ia-64 way is the correct one. Any comment?
> 
> IA64 is probably correct, but changing this might break existing programs.

This could only break programs using the hardware debug registers and following
across clone.

> Would that be worth the change? What advantage would you have from it.
> 
It would be nice to have a uniform behavior across architectures on this.
this is purely on OS policy descision. As I said, there is enough support
in ptrace (and probably in utrace) to catch the clone event and setup the
breakpoints in the new task if requested.

The reason I detected this is because the pfmon tool was entering some
infinite loop on SIGTRAP searching for breakpoints it had not set on a
child process. The pfmon tool was designed on IA-64, so it did not assume
breakpoints were systematically inherited quite the contrary as it provides
an option to explicitely inherit them.

> > Furthermore, on i386/x86-64, when switching out from a task with TIF_DEBUG
> > enabled to another which does not, it seems we do not clear the debug
> > registers (at least dr7) so they become inactive.
> 
> You mean they leak? Perhaps they should be cleared.
> 
Well, a ptrace expert pointed out to me that there is a controlled
leak to the next thread. That leak is terminated in traps.c by noticing
that you get a breakpoint trap but in a task which has debugreg[7]=0.
In that case, the kernel simply clears dr7 to shut down any subsequent
breakpoint traps. That kind of lazy stop, saves having to clear dr7 in
__switch_to() when switching from a task using the debug registers to
one which does not. i still have to convince myself this works in all cases,
especially if that task suddenly starts using the debug registers and program
the other debug registers BEFORE dr7 (assuming it was zero).

-- 
-Stephane
