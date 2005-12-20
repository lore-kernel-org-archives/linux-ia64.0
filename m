From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 20 Dec 2005 18:16:08 +0000
Subject: Re: [Perfctr-devel] Re: quick overview of the perfmon2 interface
Message-Id: <20051220181608.GD5516@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com> <20051220025156.a86b418f.akpm@osdl.org> <12c511ca0512201005k4d499b57v724815258f80322@mail.gmail.com>
In-Reply-To: <12c511ca0512201005k4d499b57v724815258f80322@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Andrew,

I will reply to your comments in details.

On Tue, Dec 20, 2005 at 10:05:11AM -0800, Tony Luck wrote:
> > >       The interface also supports automatic randomization of the reset value
> > >       for a PMD after an overflow.
> >
> > Why would one want to randomise the PMD after an overflow?
> 
> To get better data.  Using a constant reload value may keep measuring the
> same spot in the application if you are using a sample frequency that
> matches some repeat pattern in the application (and Murphy's law says
> that you'll hit this a lot).
> 
Yes, Tony is right.

For several sampling measurments which are using events that occur very
frequently such as branches, it becomes very important to avoid getting
in lockstep with the execution. Using prime numbers is not always enough
and randomization is the best way to solve this problem.

We have ecountered this when David Mosberger was developing
q-syscollect for Linux/IA64. This tool is sampling return branches
using the MckInley Branch Trace Buffer. With the collected samples
it is possible to build a statistical call graph (a la gprof).
Without randomization, the samples were so biased that the data
was unusable. With randomization, the data was very close to actual
call graph as measured by gprof. The same argument applies to
sampling for cache misses, you want to make sure you are not
always capturing the same cache misses. 

The random number generator does not have to be super fancy. That's why
we use the Carta algorithm, it is simple and fast and gives us very
good samples.

-- 

-Stephane
