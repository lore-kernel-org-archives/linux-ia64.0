From: Grant Grundler <iod00d@hp.com>
Date: Sat, 30 Apr 2005 01:02:18 +0000
Subject: Re: Simple Stupid Performance counters
Message-Id: <20050430010218.GC26482@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 29, 2005 at 01:14:33PM -0700, Christoph Lameter wrote:
> This patch allows the use of simple performance counters to measure time
> intervals in the kernel source code. This allows a detailed analysis of the
> time spend and the amount of data processed in specific code sections of the
> kernel.

I've hacked similar things for measuring interrupt cost and DMA mapping costs.
In general, I like this idea, but the implementation needs to be even
simpler and lighter weight.

I would also like to see this code be a buildtime option along with the
other CONFIG_DEBUG_KERNEL stuff.  (e.g. CONFIG_SCHEDSTATS).
This is not something I want enabled generally in production kernels.

And the usage examples in mm/memory.c should have local "#define ENABLE_PERF"
to enable (or disable) collection of those stats instead of always being on.
While it is fairly light weight, such stats collecting does effect
performance on both parisc and ia64 platforms I have tested.

> Cycle counters are not consistent across different processors.

I haven't needed to test for this specifically.
I normally can detect and discard the occasional error due to this
manually. 

Besides, since this patch steal 8 bits from the cycle counter readings
to save off the CPU ID, the duration that can be measured is smaller
(16M cycles vs 4B cycles on 32-bit) and thus less likely to have
moved to a different CPU.

...
> Index: linux-2.6.11/include/linux/perf.h
> =================================> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6.11/include/linux/perf.h	2005-04-29 13:04:31.000000000 -0700
> @@ -0,0 +1,32 @@
> +/*
> + * Performance Counters and Measurement macros
> + * (C) 2005 Silicon Graphics Incorporated
> + * by Christoph Lameter <clameter@sgi.com>, April 2005
> + *
> + * Counters are calculated using the cycle counter. If a process
> + * is migrated to another cpu during the measurement then the measurement
> + * is invalid.
> + *
> + * We cannot disable preemption during measurement since that may interfere
> + * with other things in the kernel and limit the usefulness of the counters.
> + */
> +
> +#include <linux/smp.h>
> +
> +extern void pc(const char *name, unsigned long t1, unsigned long bytes);
> +
> +/* Type for measurements */
> +#define PC_T unsigned long

People are not going to like PC_T.
I've been "encouraged" to use basic types (e.g. unsigned long) directly.

But to make compilation conditional, somthing like this might help:
#ifdef CONFIG_COUNT_CYCLES
#define PC_DECL(n)	unsigned long #n;
#else
#define PC_DECL(n)
#endif

(that might need "##n" instead of "#n" - not sure off hand.)


> +/* Macro for setting the startpoint of the stopwatch */
> +#define PC_START(x) x=(get_cycles() << 8) + smp_processor_id()
> +
> +/* Combination of the two. Define startpoint and set it */
> +#define INITIALIZED_PC_T(x) unsigned long x = (get_cycles() << 8) + smp_processor_id()

Could this be:
	#define INITIALIZED_PC_T(x) unsigned long x = PC_START(x);

instead?


> +#define cycles_to_ns(x) (((x) * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT)

I personally prefer to get raw cycle count numbers since that's what
is actually measured.  The point of measuring cycles is to get precise
information about particular code sequences.  I don't like the additional
math muddling with the data.

> +DEFINE_PER_CPU(struct pc_s [MAXCOUNT], counters);

I was thinking this might be part of PC_DECL...more below.

> +
> +void pc(const char *text, unsigned long t1, unsigned long bytes)
> +{
> +	struct pc_s *p = &get_cpu_var(counters)[0];
> +	unsigned long time = get_cycles();

I've normally needed this part (get_cycles) to be inline to get
the accuracy I want. The function call overhead will interfer
even more with whatever it is I'm trying to measuring. Adding
a subroutine calls just disturbs the resulting machine code
too much.

> +	int h = full_name_hash(text, strlen(text)) % MAXCOUNT;
> +	int count = MAXCOUNT;
> +
> +	while (count && p[h].text && strcmp(p[h].text,text)) {
> +		h = (h+1) % MAXCOUNT;
> +		count--;
> +	}

I'm not liking this bit too much either. Could each PC_DECL()
use it's own per CPU struct and then hardcode a reference to
that struct based on the name of the counter?

> +	if (unlikely(!count)) {
> +		printk(KERN_ERR "perfcount: too many counters. Measurement ignored.\n");
> +		goto out;
> +	}

Having each counter declare it's own per CPU space would avoid this
business too. I realize this will bloat the kernel data...but I
only expect very limited use of something like this in any
given kernel.

> +	time = cycles_to_ns(time - (t1 >> 8));

I'd rather see this conversion take place in /proc or /sys output
instead of inside the critical code path. The less we do inside
the code we are trying to measure, the better our measurement
will be.

> +	if (unlikely(time > (1UL << (BITS_PER_LONG - 9)))) {
> +		printk(KERN_ERR "perfcount: invalid time difference. Measurement ignored.\n");
> +		goto out;
> +	};

By tracking the CPU ID in the same word as the cycle counter, we
reduce the length of time we can measure on 32-bit systems.
IIRC, 650Mhz box will roll the 32-bit cycle counter every ~20 seconds.
Taking 8 bits off of that makes that max time that can be measured
pretty short. That's probably ok for most uses (inside one function)
but will fail for some. 24 bits is only 16 million cycles. I've seen
code sit in the IRQ handler for 800K-1M cycles under pretty trivial
conditions (average was < 200K cycles in the interrupt handler when
under SCSI disk IO load). 16 million cycles on a 2Ghz system
is less than one jiffie if I'm doing the math right.


> +/* Print a set of statistical values in the form sum(max/avg/min) */
> +static void pc_print(struct seq_file *s, const struct unit_v_s *u, unsigned long count,
> +		 unsigned long sum, unsigned long min, unsigned long max)
> +{
> +	pval(s, sum, u);
> +	seq_putc(s,'(');
> +	pval(s, min, u);
> +	seq_putc(s,'/');
> +	pval(s, (sum + count/2 ) / count, u);
> +	seq_putc(s,'/');
> +	pval(s, max, u);
> +	seq_putc(s,')');
> +}

Nice - I've had to do this by hand every time I hack something up like this.


Gotta run. I think I hit the main issues I care about.

thanks,
grant
