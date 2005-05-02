From: Grant Grundler <iod00d@hp.com>
Date: Mon, 02 May 2005 16:04:57 +0000
Subject: Re: Simple Stupid Performance counters
Message-Id: <20050502160457.GA7609@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Apr 30, 2005 at 11:40:01AM -0700, Christoph Lameter wrote:
> On Fri, 29 Apr 2005, Grant Grundler wrote:
> 
> > Besides, since this patch steal 8 bits from the cycle counter readings
> > to save off the CPU ID, the duration that can be measured is smaller
> > (16M cycles vs 4B cycles on 32-bit) and thus less likely to have
> > moved to a different CPU.
> 
> The cycle counter is 64 bit on IA32. We can still measure 2^56
> cycles.

Can one atomically read it when running in ia32 mode?

In anycase, it's not for other 32-bit arches including parisc.


> > > +#define cycles_to_ns(x) (((x) * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT)
> >
> > I personally prefer to get raw cycle count numbers since that's what
> > is actually measured.  The point of measuring cycles is to get precise
> > information about particular code sequences.  I don't like the additional
> > math muddling with the data.
> 
> The problem is that the cycles are not transferable between machines with
> different clock speed.

1) I think it's misleading - like drawing conclusions from bogomips. 
2) Userspace can do the conversion when reading /proc or /sys

> > I've normally needed this part (get_cycles) to be inline to get
> > the accuracy I want. The function call overhead will interfer
> > even more with whatever it is I'm trying to measuring. Adding
> > a subroutine calls just disturbs the resulting machine code
> > too much.
> 
> The function is quit complex. No chance.

Yeah, that's the problem. I don't think that part of it needs
to be that complex to be useful.

> > I'm not liking this bit too much either. Could each PC_DECL()
> > use it's own per CPU struct and then hardcode a reference to
> > that struct based on the name of the counter?
> 
> Nope. You need to consider the cpu local counters.

Aren't they all using get_cycles?
I thought every PC_DECL() would introduce another CPU local counter.

> All of this will never fit into an inline.

PC_DECL() isn't intended to be inline.

I suspect we don't have the same "vision" in terms of how
this facility would be used. I expect only developers to use
this during developement (conditional compilation).
ie a few data points are measured and then removed/disabled.
Sounds like you expect some of the data points to be permanent.

> > > +	time = cycles_to_ns(time - (t1 >> 8));
> >
> > I'd rather see this conversion take place in /proc or /sys output
> > instead of inside the critical code path. The less we do inside
> > the code we are trying to measure, the better our measurement
> > will be.
> 
> Hmm. That is an idea that I need to consider.

Of things I suggested, that's #2 after using get_cycles() inline.

> > By tracking the CPU ID in the same word as the cycle counter, we
> > reduce the length of time we can measure on 32-bit systems.
> 
> See my comment above. 32 bit systems can have 64 bit counters.

*can* - but not all do. Maybe use of CPU_ID needs to be per arch.
Well, leave it generic for now and we can sort out how to recover the
8-bits later if someone needs more bits on their pet arch.

> Ok. I will post a new version when I get around to it.

cool - thanks,
grant
