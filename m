From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 29 Sep 2006 09:30:01 +0000
Subject: Re: 2.6.18 perfmon new code base + libpfm + pfmon
Message-Id: <20060929093001.GI20238@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060926143420.GF14550@frankl.hpl.hp.com> <p7364f8jvjc.fsf@verdi.suse.de> <20060928075608.GB18245@frankl.hpl.hp.com> <200609281005.08518.ak@suse.de>
In-Reply-To: <200609281005.08518.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@osdl.org

Andi,

On Thu, Sep 28, 2006 at 10:05:08AM +0200, Andi Kleen wrote:
> > PAPI people for instance.
> > 
> > The P4 PMU has independent counters, i.e., enable bits. The issue is that to stop a counter
> > requires clearing the CCCR which also contains the overflow information (has the counter
> > overflowed?). So you need to read the CCCR, save the value somewhere, clear the CCCR.
> > You need some save area that you can safely access without grabbing any lock (because you
> > are in the NMI handler).
> 
> Not sure what the lock would be needed for. It is only a per CPU variable that doesn't
> need synchronization no?

The CCCR register is by definition a per-CPU entity. However, the perfmon context where the
CCCR is saved is not. Any thread with access to the file descriptor can gain access to the
context. This can occur from any CPU. Of course, we do have checks in place but they
run after the context lock is held. The main restriction is that a thread cannot operate on
a context attached to another thread unless that thread is stopped (checked via ptrace_check_attach).
Yet there are a few perfmon syscalls, for which this restriction does not apply because they
do not need to touch the PMU hardware, yet they modify the context state.

I think this could work on P4, if we could clear the CCCR and yet retain enough state to detect
which counter(s) overflowed. On P6, where there is not overflow bit in the control register, we
simply check the upper bits on the counters. We could probably do the same for P4.

-- 
-Stephane
