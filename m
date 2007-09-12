From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Wed, 12 Sep 2007 23:00:37 +0000
Subject: Re: [PATCH] local_t protection (critical section)
Message-Id: <20070912230037.GA1571@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com> <20070904200429.GD8157@Krystal> <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com> <20070905130411.GB11880@Krystal> <Pine.LNX.4.64.0709121530220.3835@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0709121530220.3835@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

* Christoph Lameter (clameter@sgi.com) wrote:
> On Wed, 5 Sep 2007, Mathieu Desnoyers wrote:
> 
> > Index: linux-2.6-lttng/include/asm-generic/local.h
> > =================================> > --- linux-2.6-lttng.orig/include/asm-generic/local.h	2007-09-04 15:32:02.000000000 -0400
> > +++ linux-2.6-lttng/include/asm-generic/local.h	2007-09-05 08:50:47.000000000 -0400
> > @@ -46,6 +46,15 @@ typedef struct
> >  #define local_add_unless(l, a, u) atomic_long_add_unless((&(l)->a), (a), (u))
> >  #define local_inc_not_zero(l) atomic_long_inc_not_zero(&(l)->a)
> >  
> > +#define local_enter_save(flags) local_irq_save(flags)
> > +#define local_exit_restore(flags) local_irq_restore(flags)
> > +#define local_enter() local_irq_disable()
> > +#define local_exit() local_irq_enable()
> > +#define local_nest_irq_save(flags) (flags)
> > +#define local_nest_irq_restore(flags) (flags)
> > +#define local_nest_irq_disable()
> > +#define local_nest_irq_enable()
> > +
> 
> This list is going to increase with RT support in SLUB? Argh.
> 

AFAIK, there is no difference between local irq save/restore in mainline
VS -RT. The same applies to preempt disable/enable.

The only thing we have to make sure is that the irq disable and
preempt disable code paths are short and O(1).

> 
> > Index: linux-2.6-lttng/include/asm-i386/local.h
> > =================================> > --- linux-2.6-lttng.orig/include/asm-i386/local.h	2007-09-04 15:28:52.000000000 -0400
> > +++ linux-2.6-lttng/include/asm-i386/local.h	2007-09-05 08:49:19.000000000 -0400
> > @@ -194,6 +194,23 @@ static __inline__ long local_sub_return(
> >  })
> >  #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
> >  
> > +#define local_enter_save(flags) \
> > +	do { \
> > +		(flags); \
> > +		preempt_disable(); \
> > +	} while (0)
> 
> 
> > +#define local_exit_restore(flags) \
> > +	do { \
> > +		(flags); \
> > +		preempt_enable(); \
> > +	} while (0)
> 
> 
> This does not result in warnings because a variable is not used or used 
> uninitialized?

Because the variable is not used at all if I don't put the "(flags)"
(gcc warns about this).

I'm glad that some of the proposed changes may help. I'll let the
cmpxchg_local patches sleep for a while so I can concentrate my efforts
on text edit lock, immediate values and markers. I think what we'll
really need for the cmpxchg_local is two flavors: one that is as atomic
as possible (for things such as tracing), and the other one the fastest
possible (potentially using irq disable). A lot of per architecture
testing/fine tuning will be required though, and I don't have the
hardware to do this.

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
