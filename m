From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 14 Jan 2016 22:20:46 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114222046.GH3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
 <20160113104516.GE25458@arm.com>
 <56969F4B.7070001@imgtec.com>
 <20160113204844.GV6357@twins.programming.kicks-ass.net>
 <5696BA6E.4070508@imgtec.com>
 <20160114120445.GB15828@arm.com>
 <56980145.5030901@imgtec.com>
 <20160114204827.GE3818@linux.vnet.ibm.com>
 <56981212.7050301@imgtec.com>
In-Reply-To: <56981212.7050301@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.netlin

On Thu, Jan 14, 2016 at 01:24:34PM -0800, Leonid Yegoshin wrote:
> On 01/14/2016 12:48 PM, Paul E. McKenney wrote:
> >
> >So SYNC_RMB is intended to implement smp_rmb(), correct?
> Yes.
> >
> >You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> >smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> 
> If smp_read_barrier_depends() is used to separate not only two reads
> but read pointer and WRITE basing on that pointer (example below) -
> yes. I just doesn't see any example of this in famous
> Documentation/memory-barriers.txt and had no chance to know what you
> use it in this way too.

Well, Documentation/memory-barriers.txt was intended as a guide for Linux
kernel hackers, and not for hardware architects.  The need for something
more precise has become clear over the past year or two, and I am working
on it with some heavy-duty memory-model folks.  But all previous memory
models have been for a specific CPU architecture, so doing one for the
intersection of several is offering up some complications.  I therefore
cannot yet provide a completion date.

That said, I still suggest use of SYNC_ACQUIRE for read_barrier_depends().

> >The reason for this is that smp_read_barrier_depends() must order the
> >pointer load against any subsequent read or write through a dereference
> >of that pointer.
> 
> I can't see that requirement anywhere in Documents directory. I mean
> - the words "write through a dereference of that pointer" or similar
> for smp_read_barrier_depends.

No worries, I will add one.  Please see the end of this message for an
initial patch.

Please understand that Documentation/memory-barriers.txt is a living
document:

v4.4: Two changes
v4.3: Three changes
v4.2: Six changes
v4.1: Three changes
v4.0: Two changes

It tends to change as we locate corner cases either in hardware or
in software use cases/APIs.

> >   For example:
> >
> >	p = READ_ONCE(gp);
> >	smp_rmb();
> >	r1 = p->a; /* ordered by smp_rmb(). */
> >	p->b = 42; /* NOT ordered by smp_rmb(), BUG!!! */
> >	r2 = x; /* ordered by smp_rmb(), but doesn't need to be. */
> >
> >In contrast:
> >
> >	p = READ_ONCE(gp);
> >	smp_read_barrier_depends();
> >	r1 = p->a; /* ordered by smp_read_barrier_depends(). */
> >	p->b = 42; /* ordered by smp_read_barrier_depends(). */
> >	r2 = x; /* not ordered by smp_read_barrier_depends(), which is OK. */
> >
> >Again, if your hardware maintains local ordering for address
> >and data dependencies, you can have read_barrier_depends() and
> >smp_read_barrier_depends() be no-ops like they are for most
> >architectures.
> 
> It is not so simple, I mean "local ordering for address and data
> dependencies". Local ordering is NOT enough. It happens that current
> MIPS R6 doesn't require in your example smp_read_barrier_depends()
> but in discussion it comes out that it may not. Because without
> smp_read_barrier_depends() your example can be a part of Will's
> WRC+addr+addr and we found some design which easily can bump into
> this test. And that design actually performs "local ordering for
> address and data dependencies" too.

As noted in another email in this thread, I do not believe that
WRC+addr+addr needs to be prohibited.  Sounds like Will and I need to
get our story straight, though.

Will?

							Thanx, Paul

------------------------------------------------------------------------

commit 955720966e216b00613fcf60188d507c103f0e80
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Thu Jan 14 14:17:04 2016 -0800

    documentation: Subsequent writes ordered by rcu_dereference()
    
    The current memory-barriers.txt does not address the possibility of
    a write to a dereferenced pointer.  This should be rare, but when it
    happens, we need that write -not- to be clobbered by the initialization.
    This commit therefore adds an example showing a data dependency ordering
    a later data-dependent write.
    
    Reported-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index f49c15f7864f..c66ba46d8079 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -555,6 +555,30 @@ between the address load and the data load:
 This enforces the occurrence of one of the two implications, and prevents the
 third possibility from arising.
 
+A data-dependency barrier must also order against dependent writes:
+
+	CPU 1		      CPU 2
+	========	      =======+	{ A = 1, B = 2, C = 3, P = &A, Q = &C }
+	B = 4;
+	<write barrier>
+	WRITE_ONCE(P, &B);
+			      Q = READ_ONCE(P);
+			      <data dependency barrier>
+			      *Q = 5;
+
+The data-dependency barrier must order the read into Q with the store
+into *Q.  This prohibits this outcome:
+
+	(Q = B) && (B = 4)
+
+Please note that this pattern should be rare.  After all, the whole point
+of dependency ordering is to -prevent- writes to the data structure, along
+with the expensive cache misses associated with those writes.  This pattern
+can be used to record rare error conditions and the like, and the ordering
+prevents such records from being lost.
+
+
 [!] Note that this extremely counterintuitive situation arises most easily on
 machines with split caches, so that, for example, one cache bank processes
 even-numbered cache lines and the other bank processes odd-numbered cache

