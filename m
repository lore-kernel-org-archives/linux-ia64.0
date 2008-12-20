From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 20 Dec 2008 01:45:50 +0000
Subject: Re: local_add_return
Message-Id: <200812201203.51351.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812191624.46580.rusty@rustcorp.com.au> <20081219170627.GB1339@Krystal>
In-Reply-To: <20081219170627.GB1339@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

On Saturday 20 December 2008 03:36:27 Mathieu Desnoyers wrote:
> * Rusty Russell (rusty@rustcorp.com.au) wrote:
> > Then some trace-specific typedef like "trace_counter_t" which goes to local_t
> > or atomic_(long?)_t?
> > 
> > Should be a simple patch and pretty clear.
> 
> Hrm, is it me or linking a basic type definition to a single user seems
> like the wrong approach ?

Well, it's an ongoing debate.  Old school kernel coders believe that
infrastructure should be resisted: you implement what you need to, then
if it turns out to be generically useful you put it somewhere that the
second user can access it.

Otherwise we end up with unused infrastructure, or overspecialized
infrastructure which doesn't actually meet the general need.  local_t
displays both these properties.

> The idea behind declaring new types is, to me, that they should describe
> as generally as possible what they provide and what they are. If we
> think of the future, where we might want to use such local atomic types
> for other purposes than tracing, I think we will end up regretting such
> specific naming scheme.

I can be convinced, but I'll need more than speculation.  Assuming
local_long_atomic_t, can you produce a patch which uses it somewhere else?

> local_atomic_long_t is a _new_ primitive, which cannot be
> implemented by a trivalue and differs from atomic_long_t, on more
> architectures than x86. On mips and powerpc, at least, it can be
> implemented as an atomic operation without the memory barriers, which
> improves performances a lot.

OK, you lost me here.  I don't see a memory barrier in the powerpc atomic
ops.  Is there an implied one I missed?

> I think the following scheme would be pretty simple and yet not tied to
> any specific user :
> 
> local_long_t
>   - Fast per-cpu counter, not necessarily atomic.
>     Implements long trivalues, or uses local_atomic_long_t.
> local_atomic_long_t
>   - Fast per-cpu atomic counter.
>     Implements per-cpu atomic counters or uses atomic_long_t.

From the point of view of someone trying to decide what to use, the real
difference is: use local_long_t unless you need the atomic-style operators
which are only available on local_atomic_long_t, or NMI-safe behaviour.
Is this correct?

> We could do the same with "int" type for :
> local_t
> local_atomic_t
> atomic_t
> 
> If we need smaller counters.

Erk... no, renaming one to two is bad enough.  Changing the semantics of
one and introducing three more is horrible.

If we're going to rename, I'd choose local_counter_t and local_atomic_t
(both long: I don't think there's a real penalty is there?).

Thanks,
Rusty.
