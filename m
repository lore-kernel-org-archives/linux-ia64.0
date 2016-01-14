From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 14 Jan 2016 21:34:40 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114213440.GG3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <569565DA.2010903@imgtec.com>
 <20160113104516.GE25458@arm.com>
 <56969F4B.7070001@imgtec.com>
 <20160113204844.GV6357@twins.programming.kicks-ass.net>
 <5696BA6E.4070508@imgtec.com>
 <20160114120445.GB15828@arm.com>
 <20160114161604.GT3818@linux.vnet.ibm.com>
 <5697FA0A.6040601@imgtec.com>
 <20160114201513.GI6357@twins.programming.kicks-ass.net>
 <56980933.2020801@imgtec.com>
In-Reply-To: <56980933.2020801@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.netlin

On Thu, Jan 14, 2016 at 12:46:43PM -0800, Leonid Yegoshin wrote:
> On 01/14/2016 12:15 PM, Peter Zijlstra wrote:
> >On Thu, Jan 14, 2016 at 11:42:02AM -0800, Leonid Yegoshin wrote:
> >>An the only point - please use an appropriate SYNC_* barriers instead of
> >>heavy bold hammer. That stuff was design explicitly to support the
> >>requirements of Documentation/memory-barriers.txt
> >That's madness. That document changes from version to version as to what
> >we _think_ the actual hardware does. It is _NOT_ a specification.
> >
> >You cannot design hardware from that. Its incomplete and fails to
> >specify a bunch of things. It not a mathematically sound definition of a
> >memory model.
> >
> >Please stop referring to that document for what a particular barrier
> >_should_ do.  Explain what MIPS does, so we can attempt to integrate
> >this knowledge with our knowledge of PPC/ARM/Alpha/x86/etc. and improve
> >upon our understanding of hardware and improve the Linux memory model.
> 
> I am afraid I can't help you here. It is very complicated stuff and
> a model is actually doesn't fit your assumptions about CPUs well
> without some simplifications which are based on what you want to
> have.
> 
> I say that SYNC_ACQUIRE/etc follows what you expect for smp_acquire
> etc (basing on that document). And at least two CPU models were
> tested with my patches (see it in LMO) for that last year and that
> instructions are implemented now in engineering kernel.
> 
> If you have something else in mind, you can ask me. But I prefer to
> do not deviate too much from Documentation/memory-barriers.txt, for
> exam - if it asks to have memory barrier somewhere, then I assume
> the code should have it, and please - don't ask me a test which
> violates the current version of document recommendations.
> 
> For a moment I don't see a significant changes in this document for
> MIPS Arch at least 1.5 year, and the only significant point is that
> MIPS CPU Arch doesn't have yet smp_read_barrier_depends() and
> smp_rmb() should be used instead.

Is SYNC_ACQUIRE a memory-barrier instruction that orders prior loads
against later loads and stores?  If so, and if MIPS does not do
ordering based on address and data dependencies, I suggest making
read_barrier_depends() be a SYNC_ACQUIRE rather than SYNC_RMB.

							Thanx, Paul

