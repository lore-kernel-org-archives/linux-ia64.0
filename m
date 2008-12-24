From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 24 Dec 2008 11:54:55 +0000
Subject: Re: local_add_return
Message-Id: <200812242212.57007.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812201203.51351.rusty@rustcorp.com.au> <20081222184327.GB22001@Krystal>
In-Reply-To: <20081222184327.GB22001@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

On Tuesday 23 December 2008 05:13:28 Mathieu Desnoyers wrote:
> > I can be convinced, but I'll need more than speculation.  Assuming
> > local_long_atomic_t, can you produce a patch which uses it somewhere else?
> 
> I had this patch applying over Christoph Lameter's vm tree last
> February. It did accelerate the slub fastpath allocator by using
> cmpxchg_local rather than disabling interrupts. cmpxchg_local is not
> using the local_t type, but behaves similarly to local_cmpxchg.
> 
> http://lkml.org/lkml/2008/2/28/568

OK, I'll buy that.  So we split local_t into a counter and an atomic type.

> I know that
> local_counter_long_t and local_atomic_long_t are painful to write, but
> that would follow the current atomic_t vs atomic_long_t semantics. Hm ?

OK, I've looked at how they're used, to try to figure out whether long
is the right thing.  Counters generally want to be long, but I was in doubt
about atomics; yet grep shows that atomic_long_t is quite popular.  Then
I hit struct nfs_iostats which would want a u64 and a long.  I don't think
we want local_counter_u64 etc.

Just thinking out loud, perhaps a new *type* is the wrong direction?  How
about a set of macros which take a fundamental type, such as:

	DECLARE_LOCAL_COUNTER(type, name);
	local_counter_inc(type, addr);
	...
	DECLARE_LOCAL_ATOMIC(type, name);
	local_atomic_add_return(type, addr);

This allows pointers, u32, u64, long, etc.  If a 32-bit arch can't do 64-bit
local_counter_inc easily, at least the hairy 64-bit code can be eliminated at
compile time.

Or maybe that's overdesign?
Rusty.
