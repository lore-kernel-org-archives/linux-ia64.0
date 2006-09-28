From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 28 Sep 2006 07:56:08 +0000
Subject: Re: 2.6.18 perfmon new code base + libpfm + pfmon
Message-Id: <20060928075608.GB18245@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060926143420.GF14550@frankl.hpl.hp.com> <20060926220951.39bd344f.akpm@osdl.org> <20060927224832.GA17883@frankl.hpl.hp.com> <p7364f8jvjc.fsf@verdi.suse.de>
In-Reply-To: <p7364f8jvjc.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@osdl.org

Andi,

On Thu, Sep 28, 2006 at 09:32:39AM +0200, Andi Kleen wrote:
> Stephane Eranian <eranian@hpl.hp.com> writes:
> > 
> > [ak] : separate patch for _TIF_WORK_CTXSW
> > 	- I think I submitted a TIF patch for x86-64, but unlike i386 it is not yet in mainline
> 
> If it's not in mainline yet I lost it somehow and you should resubmit.
> 
Will do.

> > [ak] : may have to add __kprobes to some functions
> > 	- started doing this on some functions. Need better understanding on when to use this
> 
> Basically when you could recurse in kprobes. 
> 
My understanding is that kprobes are triggered by breakpoints, so I am think that any 
perfmon function that can be called along the same path, i.e., traps, needs to have the
__kprobes prefix.

> > [ak] : cleaner integration with NMI watchdog
> > 	- integration done on AMD K8. Issues on P4, P6, due to PMU design
> 
> What are the issues?

This is ugly!

The P6 PMU actually has only one enable bit for all counters and it is in PERFEVTSEL0 which
you are using for NMI. Thus counters are NOT independent. Architectural perfmon looks like
it is fixing this issue.  I am not sure this is actually true based on the findings of the
PAPI people for instance.

The P4 PMU has independent counters, i.e., enable bits. The issue is that to stop a counter
requires clearing the CCCR which also contains the overflow information (has the counter
overflowed?). So you need to read the CCCR, save the value somewhere, clear the CCCR.
You need some save area that you can safely access without grabbing any lock (because you
are in the NMI handler). I cannot use the perfmon context because it could be accessed from
other processors, and I would need to grab the context lock. I need to investigate how to
do this in a different way. Maybe change the logic used to detect which counters overflowed
by not using CCCR.

> 
> > [akpm]: documentation for syscall? Is there an API specification?
> > 	- answered. In short, there exists a specification but it needs to be updated
> 
> Probably you should have man pages ready for submission to the manpage maintainer.
> That might also the second review pass on l-k easier if you supply
> them in the description.

I don't have the man pages ready yet.

-- 
-Stephane
