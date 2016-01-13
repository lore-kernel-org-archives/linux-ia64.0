From: Will Deacon <will.deacon@arm.com>
Date: Wed, 13 Jan 2016 10:45:17 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160113104516.GE25458@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
 <56945366.2090504@imgtec.com>
 <20160112092711.GP6344@twins.programming.kicks-ass.net>
 <20160112102555.GV6373@twins.programming.kicks-ass.net>
 <20160112104012.GW6373@twins.programming.kicks-ass.net>
 <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
In-Reply-To: <569565DA.2010903@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org

On Tue, Jan 12, 2016 at 12:45:14PM -0800, Leonid Yegoshin wrote:
> >The issue I have with the SYNC description in the text above is that it
> >describes the single CPU (program order) and the dual-CPU (confusingly
> >named global order) cases, but then doesn't generalise any further. That
> >means we can't sensibly reason about transitivity properties when a third
> >agent is involved. For example, the WRC+sync+addr test:
> >
> >
> >P0:
> >Wx = 1
> >
> >P1:
> >Rx = 1
> >SYNC
> >Wy = 1
> >
> >P2:
> >Ry = 1
> ><address dep>
> >Rx = 0
> >
> >
> >I can't find anything to forbid that, given the text. The main problem
> >is having the SYNC on P1 affect the write by P0.
> 
> As I understand that test, the visibility of P0: W[x] = 1 is identical to P1
> and P2 here. If P1 got X before SYNC and write to Y after SYNC then
> instruction source register dependency tracking in P2 prevents a speculative
> load of X before P2 obtains Y from the same place as P0/P1 and calculate
> address of X. If some load of X in P2 happens before address dependency
> calculation it's result is discarded.

I don't think the address dependency is enough on its own. By that
reasoning, the following variant (WRC+addr+addr) would work too:


P0:
Wx = 1

P1:
Rx = 1
<address dep>
Wy = 1

P2:
Ry = 1
<address dep>
Rx = 0


So are you saying that this is also forbidden?
Imagine that P0 and P1 are two threads that share a store buffer. What
then?

> Yes, you can't find that in MIPS SYNC instruction description, it is more
> likely in CM (Coherence Manager) area. I just pointed our arch team member
> responsible for documents and he will think how to explain that.

I tried grepping the linked documents for "coherence manager" but couldn't
find anything. Is the description you refer to available anywhere?

Will
