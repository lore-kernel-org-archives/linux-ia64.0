From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 26 Jan 2016 10:19:27 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126101927.GD6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114203430.GC3818@linux.vnet.ibm.com>
 <56980C91.1010403@imgtec.com>
 <20160114212913.GF3818@linux.vnet.ibm.com>
 <20160115085554.GF3421@worktop>
 <20160115091348.GA27936@worktop>
 <20160115174612.GV3818@linux.vnet.ibm.com>
 <20160115212714.GM3421@worktop>
 <20160115215853.GC3818@linux.vnet.ibm.com>
 <20160125164242.GF22927@arm.com>
 <20160126060322.GJ4503@linux.vnet.ibm.com>
In-Reply-To: <20160126060322.GJ4503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.ne

On Mon, Jan 25, 2016 at 10:03:22PM -0800, Paul E. McKenney wrote:
> On Mon, Jan 25, 2016 at 04:42:43PM +0000, Will Deacon wrote:
> > On Fri, Jan 15, 2016 at 01:58:53PM -0800, Paul E. McKenney wrote:
> > > On Fri, Jan 15, 2016 at 10:27:14PM +0100, Peter Zijlstra wrote:

> > > > Yes, that seems a good start. But yesterday you raised the 'fun' point
> > > > of two globally ordered sequences connected by a single local link.
> > > 
> > > The conclusion that I am slowly coming to is that litmus tests should
> > > not be thought of as linear chains, but rather as cycles.  If you think
> > > of it as a cycle, then it doesn't matter where the local link is, just
> > > how many of them and how they are connected.
> > 
> > Do you have some examples of this? I'm struggling to make it work in my
> > mind, or are you talking specifically in the context of the kernel
> > memory model?
> 
> Now that you mention it, maybe it would be best to keep the transitive
> and non-transitive separate for the time being anyway.  Just because it
> might be possible to deal with does not necessarily mean that we should
> be encouraging it.  ;-)

So isn't smp_mb__after_unlock_lock() exactly such a scenario? And would
not someone trying to implement RCsc locks using locally transitive
RELEASE/ACQUIRE operations need exactly this stuff?

That is, I am afraid we need to cover the mix of local and global
transitive operations at least in overview.
