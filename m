From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 26 Jan 2016 19:44:10 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126194410.GQ4503@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160113104516.GE25458@arm.com>
 <56969F4B.7070001@imgtec.com>
 <20160113204844.GV6357@twins.programming.kicks-ass.net>
 <5696BA6E.4070508@imgtec.com>
 <20160114120445.GB15828@arm.com>
 <56980145.5030901@imgtec.com>
 <20160114204827.GE3818@linux.vnet.ibm.com>
 <56981212.7050301@imgtec.com>
 <20160114222046.GH3818@linux.vnet.ibm.com>
 <20160126102402.GE6357@twins.programming.kicks-ass.net>
In-Reply-To: <20160126102402.GE6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Will Deacon <will.deacon@arm.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.ne

On Tue, Jan 26, 2016 at 11:24:02AM +0100, Peter Zijlstra wrote:
> On Thu, Jan 14, 2016 at 02:20:46PM -0800, Paul E. McKenney wrote:
> > On Thu, Jan 14, 2016 at 01:24:34PM -0800, Leonid Yegoshin wrote:
> > > On 01/14/2016 12:48 PM, Paul E. McKenney wrote:
> > > >
> > > >So SYNC_RMB is intended to implement smp_rmb(), correct?
> > > Yes.
> > > >
> > > >You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> > > >smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> > > 
> > > If smp_read_barrier_depends() is used to separate not only two reads
> > > but read pointer and WRITE basing on that pointer (example below) -
> > > yes. I just doesn't see any example of this in famous
> > > Documentation/memory-barriers.txt and had no chance to know what you
> > > use it in this way too.
> > 
> > Well, Documentation/memory-barriers.txt was intended as a guide for Linux
> > kernel hackers, and not for hardware architects.
> 
> Yeah, this goes under the header: memory-barriers.txt is _NOT_ a
> specification (I seem to keep repeating this).
> 
> > ------------------------------------------------------------------------
> > 
> > commit 955720966e216b00613fcf60188d507c103f0e80
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Thu Jan 14 14:17:04 2016 -0800
> > 
> >     documentation: Subsequent writes ordered by rcu_dereference()
> >     
> >     The current memory-barriers.txt does not address the possibility of
> >     a write to a dereferenced pointer.  This should be rare, 
> 
> How are these rare? Isn't:
> 
> 	rcu_read_lock()
> 	obj = rcu_dereference(ptr);
> 	if (!atomic_inc_not_zero(&obj->ref))
> 		obj = NULL;
> 	rcu_read_unlock();
> 
> a _very_ common thing to do?

It is, but it provides its own barriers, so does not need to rely on
dependency ordering.

							Thanx, Paul

