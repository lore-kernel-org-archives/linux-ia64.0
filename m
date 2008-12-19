From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Fri, 19 Dec 2008 17:06:27 +0000
Subject: Re: local_add_return
Message-Id: <20081219170627.GB1339@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812190922.57629.rusty@rustcorp.com.au> <20081219033514.GA7162@Krystal> <200812191624.46580.rusty@rustcorp.com.au>
In-Reply-To: <200812191624.46580.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

* Rusty Russell (rusty@rustcorp.com.au) wrote:
> On Friday 19 December 2008 14:05:14 Mathieu Desnoyers wrote:
> > * Rusty Russell (rusty@rustcorp.com.au) wrote:
> > But can we turn what you call "nmi_safe_t" into "local_atomic_t" then ?
> > Because we have to specify that this type must only be used as part of
> > per-cpu data with preemption disabled, and we also specify that it is
> > atomic.
> > 
> > Plus, nmi_safe_t does not make much sense on architectures without NMIs,
> > where we sometimes disable interrupts to make the modification "atomic"
> > wrt all other interrupts that can happen.
> 
> But those archs can use local_t.  I don't like either name local_t nor
> atomic_local_t, but renaming sucks too.
> 
> OK, how about a different approach?  Since there's really only one case
> where we need this local_t property outside arch-specific code, how about
> we define ARCH_LOCAL_T_TRACE_SAFE for x86?
> 
> Then some trace-specific typedef like "trace_counter_t" which goes to local_t
> or atomic_(long?)_t?
> 
> Should be a simple patch and pretty clear.
> 

Hrm, is it me or linking a basic type definition to a single user seems
like the wrong approach ?

The idea behind declaring new types is, to me, that they should describe
as generally as possible what they provide and what they are. If we
think of the future, where we might want to use such local atomic types
for other purposes than tracing, I think we will end up regretting such
specific naming scheme. I don't think the argument "because the type has
only one arch-independent user" holds, because the idea behind new types
is that they _will_ be used by others eventually. For instance, we've
done some work on moving the slub allocator to such local atomic
operations last year, and it gave very good results on architectures
where disabling interrupt is costly (threefold acceleration of the
fastpath).

In your trace_counter_t proposal, you don't take into account that (what
I call) local_atomic_long_t is a _new_ primitive, which cannot be
implemented by a trivalue and differs from atomic_long_t, on more
architectures than x86. On mips and powerpc, at least, it can be
implemented as an atomic operation without the memory barriers, which
improves performances a lot.

I think the following scheme would be pretty simple and yet not tied to
any specific user :

local_long_t
  - Fast per-cpu counter, not necessarily atomic.
    Implements long trivalues, or uses local_atomic_long_t.
local_atomic_long_t
  - Fast per-cpu atomic counter.
    Implements per-cpu atomic counters or uses atomic_long_t.
atomic_long_t
  - Global atomic counter.
    Implements globally synchronized atomic operations.

We could do the same with "int" type for :
local_t
local_atomic_t
atomic_t

If we need smaller counters.

Mathieu


> Thanks,
> Rusty.

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
