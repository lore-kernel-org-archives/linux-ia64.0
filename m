From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 19 Dec 2008 05:54:53 +0000
Subject: Re: local_add_return
Message-Id: <200812191624.46580.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812190922.57629.rusty@rustcorp.com.au> <20081219033514.GA7162@Krystal>
In-Reply-To: <20081219033514.GA7162@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, Christoph Lameter <christoph@lameter.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Martin Bligh <mbligh@google.com>

On Friday 19 December 2008 14:05:14 Mathieu Desnoyers wrote:
> * Rusty Russell (rusty@rustcorp.com.au) wrote:
> But can we turn what you call "nmi_safe_t" into "local_atomic_t" then ?
> Because we have to specify that this type must only be used as part of
> per-cpu data with preemption disabled, and we also specify that it is
> atomic.
> 
> Plus, nmi_safe_t does not make much sense on architectures without NMIs,
> where we sometimes disable interrupts to make the modification "atomic"
> wrt all other interrupts that can happen.

But those archs can use local_t.  I don't like either name local_t nor
atomic_local_t, but renaming sucks too.

OK, how about a different approach?  Since there's really only one case
where we need this local_t property outside arch-specific code, how about
we define ARCH_LOCAL_T_TRACE_SAFE for x86?

Then some trace-specific typedef like "trace_counter_t" which goes to local_t
or atomic_(long?)_t?

Should be a simple patch and pretty clear.

Thanks,
Rusty.
