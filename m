From: Grant Grundler <iod00d@hp.com>
Date: Tue, 27 Jun 2006 16:51:25 +0000
Subject: Re: 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <20060627165125.GA19132@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606270159_MC3-1-C391-1A2A@compuserve.com> <20060627143204.GC16417@frankl.hpl.hp.com>
In-Reply-To: <20060627143204.GC16417@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephane Eranian <eranian@hpl.hp.com>
Cc: Chuck Ebbert <76306.1226@compuserve.com>, linux-kernel <linux-kernel@vger.kernel.org>, perfctr-devel <perfctr-devel@lists.sourceforge.net>, linux-ia64 <linux-ia64@vger.kernel.org>, perfmon <perfmon@napali.hpl.hp.com>, oprofile-list <oprofile-list@lists.sourceforge.net>

On Tue, Jun 27, 2006 at 07:32:04AM -0700, Stephane Eranian wrote:
...
> > 5006 hardware interrupts in 10 seconds, 16359 interrupt-disable events =>
> > the kernel disabled interrupts 11353 times for critical sections.  To get
> > useful results it looks like booting with idle=poll and disabling cpufreq
> > is needed, though, since interrupts_masked_cycles (non-edge mode) counts
> > even when the CPU is halted:
> 
> Yes, I think you need to be careful with the idle thread, some events may or
> may not count when going low-power. I think it is best to avoid going
> low-power for measurements.

Any benchmarking that involves IA64 idle thread is strongly reccomended
to use "nohalt" option. It's about a 15-20% performance difference
on some interrupt intensive benchmarks (e.g. netperf TCP_RR).

If someone has measured the delta for other architectures that
go into a "low power" state in idle thread, I'd be grateful if
they posted the results or mailed them to me.

thanks,
grant
