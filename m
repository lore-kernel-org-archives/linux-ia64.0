From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Mon, 22 Dec 2008 18:43:28 +0000
Subject: Re: local_add_return
Message-Id: <20081222184327.GB22001@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812191624.46580.rusty@rustcorp.com.au> <20081219170627.GB1339@Krystal> <200812201203.51351.rusty@rustcorp.com.au>
In-Reply-To: <200812201203.51351.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

* Rusty Russell (rusty@rustcorp.com.au) wrote:
> On Saturday 20 December 2008 03:36:27 Mathieu Desnoyers wrote:
> > * Rusty Russell (rusty@rustcorp.com.au) wrote:
> > > Then some trace-specific typedef like "trace_counter_t" which goes to local_t
> > > or atomic_(long?)_t?
> > > 
> > > Should be a simple patch and pretty clear.
> > 
> > Hrm, is it me or linking a basic type definition to a single user seems
> > like the wrong approach ?
> 
> Well, it's an ongoing debate.  Old school kernel coders believe that
> infrastructure should be resisted: you implement what you need to, then
> if it turns out to be generically useful you put it somewhere that the
> second user can access it.
> 
> Otherwise we end up with unused infrastructure, or overspecialized
> infrastructure which doesn't actually meet the general need.  local_t
> displays both these properties.
> 

Yes.. well given every iteration on that kind of primitive touches _all_
architectures supported by Linux, I think it's good to think a bit about
the design in advance to minimize the amout of wasted effort. Especially
because it requires some coordination between many architecture
maintainers.

> > The idea behind declaring new types is, to me, that they should describe
> > as generally as possible what they provide and what they are. If we
> > think of the future, where we might want to use such local atomic types
> > for other purposes than tracing, I think we will end up regretting such
> > specific naming scheme.
> 
> I can be convinced, but I'll need more than speculation.  Assuming
> local_long_atomic_t, can you produce a patch which uses it somewhere else?
> 

I had this patch applying over Christoph Lameter's vm tree last
February. It did accelerate the slub fastpath allocator by using
cmpxchg_local rather than disabling interrupts. cmpxchg_local is not
using the local_t type, but behaves similarly to local_cmpxchg.

http://lkml.org/lkml/2008/2/28/568


> > local_atomic_long_t is a _new_ primitive, which cannot be
> > implemented by a trivalue and differs from atomic_long_t, on more
> > architectures than x86. On mips and powerpc, at least, it can be
> > implemented as an atomic operation without the memory barriers, which
> > improves performances a lot.
> 
> OK, you lost me here.  I don't see a memory barrier in the powerpc atomic
> ops.  Is there an implied one I missed?
> 

Look for LWSYNC_ON_SMP and ISYNC_ON_SMP in 
arch/powerpc/include/asm/atomic.h

They map to the lwsync and isync instruction, which are more or less
memory ops and instruction execution order barriers. They become both
unneeded when modifying per-cpu data from a single CPU.

> > I think the following scheme would be pretty simple and yet not tied to
> > any specific user :
> > 
> > local_long_t
> >   - Fast per-cpu counter, not necessarily atomic.
> >     Implements long trivalues, or uses local_atomic_long_t.
> > local_atomic_long_t
> >   - Fast per-cpu atomic counter.
> >     Implements per-cpu atomic counters or uses atomic_long_t.
> 
> From the point of view of someone trying to decide what to use, the real
> difference is: use local_long_t unless you need the atomic-style operators
> which are only available on local_atomic_long_t, or NMI-safe behaviour.
> Is this correct?
> 

Yes.

> > We could do the same with "int" type for :
> > local_t
> > local_atomic_t
> > atomic_t
> > 
> > If we need smaller counters.
> 
> Erk... no, renaming one to two is bad enough.  Changing the semantics of
> one and introducing three more is horrible.
> 
> If we're going to rename, I'd choose local_counter_t and local_atomic_t
> (both long: I don't think there's a real penalty is there?).
> 

The penality is only space and wasted cache-lines whenever the data fits
in smaller data types, but I think we can start with a single data type
(long) and add more if needed. I agree with you on renaming, it's bad.
People trying to forward port their code will have a hard time managing
the type behavior change, especially if the compiler does not complain.
local_counter_t and local_atomic_t seems good to me, except the fact
that atomic_t maps to "int" and local_atomic_t would map to "long",
which might be unexpected. If possible, I'd try to follow the current
semantics of "atomic_t" for int and "atomic_long_t" for long, because I
think those types should offer a similar interface. I know that
local_counter_long_t and local_atomic_long_t are painful to write, but
that would follow the current atomic_t vs atomic_long_t semantics. Hm ?

Mathieu

> Thanks,
> Rusty.
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
