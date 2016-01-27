From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jan 2016 08:39:05 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160127083905.GK6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114212913.GF3818@linux.vnet.ibm.com>
 <20160115085554.GF3421@worktop>
 <20160115091348.GA27936@worktop>
 <20160115174612.GV3818@linux.vnet.ibm.com>
 <20160115212714.GM3421@worktop>
 <20160115215853.GC3818@linux.vnet.ibm.com>
 <20160125164242.GF22927@arm.com>
 <20160126060322.GJ4503@linux.vnet.ibm.com>
 <20160126101927.GD6357@twins.programming.kicks-ass.net>
 <20160126201339.GW4503@linux.vnet.ibm.com>
In-Reply-To: <20160126201339.GW4503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.ne

On Tue, Jan 26, 2016 at 12:13:39PM -0800, Paul E. McKenney wrote:
> On Tue, Jan 26, 2016 at 11:19:27AM +0100, Peter Zijlstra wrote:

> > So isn't smp_mb__after_unlock_lock() exactly such a scenario? And would
> > not someone trying to implement RCsc locks using locally transitive
> > RELEASE/ACQUIRE operations need exactly this stuff?
> > 
> > That is, I am afraid we need to cover the mix of local and global
> > transitive operations at least in overview.
> 
> True, but we haven't gotten to locking yet.

The mythical smp_mb__after_release_acquire() then ;-)

(and yes, I know you're going to say we don't have that)

> That said, I would argue
> that smp_mb__after_unlock_lock() upgrades locks to transitive, and
> thus would not be an exception to the "no combining transitive and
> non-transitive steps in cycles" rule.

But But But ;-) It does that exactly by combining. I suspect this is
(partly) the source of your SC chains with one PC link example.


