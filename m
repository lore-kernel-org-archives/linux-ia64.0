From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 26 Jun 2006 22:37:17 +0000
Subject: Re: 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <20060626223716.GA16082@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606261336_MC3-1-C384-7981@compuserve.com>
In-Reply-To: <200606261336_MC3-1-C384-7981@compuserve.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chuck Ebbert <76306.1226@compuserve.com>
Cc: oprofile-list <oprofile-list@lists.sourceforge.net>, perfmon <perfmon@napali.hpl.hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, perfctr-devel <perfctr-devel@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>

Chuck,

On Mon, Jun 26, 2006 at 01:33:03PM -0400, Chuck Ebbert wrote:
> > Also a new version of pfmon, pfmon-3.2-060621, to take advantage of the update in libpfm:
> > 
> >       - support for 32-bit mode AMD64 processors
> >       - updated event name parsing to prepare for separate
> >         event unit mask management (Kevin Corry)
> >       - fix the detection of unavailable PMC registers. it was causing crashes
> >         when used with sampling.
> > 
> > Note that I have tested 32-bit compiled libpfm,pfmon running on an 64-bit AMD
> > perfmon kernel. I have not tested on a 32-bit AMD linux kernel because I don't
> > have such setup. I would appreciate any feedback on this.
> 
> 32-bit works great.  Unfortunately, pfmon is far too limited for serious kernel
> monitoring AFAICT.  E.g. you can't select edge counting instead of cycle
> counting.  So you can count how many clock cycles were spent with interrupts

I put in an option to enable this mode, do pfmon --help. I think it's called
edge-mask.

> disabled but you can't count how many times they were disabled.  That's too bad
> because using pfmon is so easy compared to writing a program.
> 
Try the option, and let me know if it does not work for you.

> And is someone working on kernel profiling tools that use the perfmon2
> infrastructure on i386?  I'd like to see kernel-based profiling that lets
> you use something like the existing 'readprofile' to retrieve results.  This
> would be a lot better than the current timer-based profiling.
> 
You can do this on your athlon using pfmon already, you need to enable a
different sampling module. Here is an example:

$ pfmon --smpl-module=inst-hist -ecpu_clk_unhalted -k --long-smpl-period0000 \
     --resolve-addr --system-wide --session-timeout

This will sample (period of 100,000 cpu_clk_unhalted) in the kernel ONLY for 10s and print  a flat
profile sorted by #samples/instruction addresses. You can chose any event you want. Note that you can
also use this output format in per-thread mode.

Hope this helps.
-- 
-Stephane
