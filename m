From: Grant Grundler <iod00d@hp.com>
Date: Mon, 26 Jun 2006 19:32:56 +0000
Subject: Re: 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <20060626193256.GE14684@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606261336_MC3-1-C384-7981@compuserve.com>
In-Reply-To: <200606261336_MC3-1-C384-7981@compuserve.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chuck Ebbert <76306.1226@compuserve.com>
Cc: Stephane Eranian <eranian@hpl.hp.com>, oprofile-list <oprofile-list@lists.sourceforge.net>, perfmon <perfmon@napali.hpl.hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, perfctr-devel <perfctr-devel@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Jun 26, 2006 at 01:33:03PM -0400, Chuck Ebbert wrote:
> 32-bit works great.  Unfortunately, pfmon is far too limited for serious
> kernel monitoring AFAICT.

I think "far too limited for serious kernel monitoring" is not a fair
statement. One can do some very interesting things as I presented
two years ago at OLS:
	http://iou.parisc-linux.org/ols_2004/pfmon_for_iodorks.pdf

It's just a _very_ complex subsystem and has a steep learning curve
to do some of the more complex things that one might like.

> E.g. you can't select edge counting instead
> of cycle counting.  So you can count how many clock cycles were spent
> with interrupts disabled but you can't count how many times they were
> disabled.

At first glance, this example sounds more like a limitation of the HW
and not the SW.

> And is someone working on kernel profiling tools that use the perfmon2
> infrastructure on i386?  I'd like to see kernel-based profiling that lets
> you use something like the existing 'readprofile' to retrieve results.  This
> would be a lot better than the current timer-based profiling.

Both are useful. I wouldn't say one of necessarily better.
FWIW, the "CPU_CYCLES" counts from pfmon aren't timer based on ia64.
AFAIK, the HW counters are sampled to gather those counts.

thanks,
grant
