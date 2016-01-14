From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 14 Jan 2016 20:46:10 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114204610.GA6373@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
 <20160113104516.GE25458@arm.com>
 <56969F4B.7070001@imgtec.com>
 <20160113204844.GV6357@twins.programming.kicks-ass.net>
 <5696BA6E.4070508@imgtec.com>
 <20160114120445.GB15828@arm.com>
 <20160114161604.GT3818@linux.vnet.ibm.com>
 <5697FA0A.6040601@imgtec.com>
 <20160114201513.GI6357@twins.programming.kicks-ass.net>
In-Reply-To: <20160114201513.GI6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: paulmck@linux.vnet.ibm.com, Will Deacon <will.deacon@arm.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.k

On Thu, Jan 14, 2016 at 09:15:13PM +0100, Peter Zijlstra wrote:
> On Thu, Jan 14, 2016 at 11:42:02AM -0800, Leonid Yegoshin wrote:
> > An the only point - please use an appropriate SYNC_* barriers instead of
> > heavy bold hammer. That stuff was design explicitly to support the
> > requirements of Documentation/memory-barriers.txt
> 
> That's madness. That document changes from version to version as to what
> we _think_ the actual hardware does. It is _NOT_ a specification.
> 
> You cannot design hardware from that. Its incomplete and fails to
> specify a bunch of things. It not a mathematically sound definition of a
> memory model.
> 
> Please stop referring to that document for what a particular barrier
> _should_ do.  Explain what MIPS does, so we can attempt to integrate
> this knowledge with our knowledge of PPC/ARM/Alpha/x86/etc. and improve
> upon our understanding of hardware and improve the Linux memory model.

That is, if you'd managed to read that file at the right point in time,
you might have through we'd be OK with requiring a barrier for
control dependencies.

We got rid of that mistake. It was based on a flawed reading of the
Alpha docs. See: 105ff3cbf225 ("atomic: remove all traces of
READ_ONCE_CTRL() and atomic*_read_ctrl()")

Similarly, while the document goes to great length to explain the
read_barrier_depends thing, nobody actually thinks its a brilliant idea
to have. Ideally we'd kill the thing the moment we drop Alpha support.

Again, memory-barriers.txt is _NOT_, I repeat, _NOT_ a hardware spec, it
is not even a recommendation. It are our best effort (but flawed)
scribbles of what we think is makes sense given the huge amount of
actual hardware we have to run on.


As to the ACQUIRE/RELEASE semantics, ARM64 actually has
multi-copy-atomic acquire/release (as does ia64, although in reality it
doesn't actually have acquire/release). PPC otoh does _NOT_ have this,
and is currently the only arch to suffer RCpc locks.

Now for a long long time we assumed our locks were RCsc, and we've
written code assuming UNLOCK x + LOCK y was in fact a full barrier with
transitiviy. Then we figured out PPC didn't actually match that. RCU is
the only piece of code we _know_ relied on that, but there might be more
out there...

So we document, for new code, that UNLOCK+LOCK isn't a MB, while at the
same time we lobby PPC to stick a full barrier in and get rid of this
stuff.

Nobody really likes RCpc locks, esp. given the history we have of
assuming RCsc.

The current document allowing for RCpc is not an endorsement thereof.
Ideally we'd _NOT_ have to worry about that. We can do without these
head-aches.


So again, stop referring to our document as a spec. Also please don't
make MIPS push the limits of weak memory models, we really can do
without the pain.
