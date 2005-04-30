From: Christoph Lameter <clameter@engr.sgi.com>
Date: Sat, 30 Apr 2005 18:40:01 +0000
Subject: Re: Simple Stupid Performance counters
Message-Id: <Pine.LNX.4.58.0504301133330.23199@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 29 Apr 2005, Grant Grundler wrote:

> Besides, since this patch steal 8 bits from the cycle counter readings
> to save off the CPU ID, the duration that can be measured is smaller
> (16M cycles vs 4B cycles on 32-bit) and thus less likely to have
> moved to a different CPU.

The cycle counter is 64 bit on IA32. We can still measure 2^56
cycles.

> > +/* Combination of the two. Define startpoint and set it */
> > +#define INITIALIZED_PC_T(x) unsigned long x = (get_cycles() << 8) + smp_processor_id()
>
> Could this be:
> 	#define INITIALIZED_PC_T(x) unsigned long x = PC_START(x);
>
> instead?

Yes that looks better.

> > +#define cycles_to_ns(x) (((x) * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT)
>
> I personally prefer to get raw cycle count numbers since that's what
> is actually measured.  The point of measuring cycles is to get precise
> information about particular code sequences.  I don't like the additional
> math muddling with the data.

The problem is that the cycles are not transferable between machines with
different clock spped.

> > +void pc(const char *text, unsigned long t1, unsigned long bytes)
> > +{
> > +	struct pc_s *p = &get_cpu_var(counters)[0];
> > +	unsigned long time = get_cycles();
>
> I've normally needed this part (get_cycles) to be inline to get
> the accuracy I want. The function call overhead will interfer
> even more with whatever it is I'm trying to measuring. Adding
> a subroutine calls just disturbs the resulting machine code
> too much.

The function is quit complex. No chance.

> I'm not liking this bit too much either. Could each PC_DECL()
> use it's own per CPU struct and then hardcode a reference to
> that struct based on the name of the counter?

Nope. You need to consider the cpu local counters. All of this will never
fit into an inline.

> > +	time = cycles_to_ns(time - (t1 >> 8));
>
> I'd rather see this conversion take place in /proc or /sys output
> instead of inside the critical code path. The less we do inside
> the code we are trying to measure, the better our measurement
> will be.

Hmm. That is an idea that I need to consider.

> By tracking the CPU ID in the same word as the cycle counter, we
> reduce the length of time we can measure on 32-bit systems.

See my comment above. 32 bit systems can have 64 bit counters.

> Gotta run. I think I hit the main issues I care about.

Ok. I will post a new version when I get around to it.
