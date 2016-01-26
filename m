From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 26 Jan 2016 10:15:43 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126101543.GC6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <5696CF08.8080700@imgtec.com> <20160114121449.GC15828@arm.com>
 <5697F6D2.60409@imgtec.com>
 <20160114203430.GC3818@linux.vnet.ibm.com>
 <56980C91.1010403@imgtec.com>
 <20160114212913.GF3818@linux.vnet.ibm.com>
 <20160115085554.GF3421@worktop>
 <20160115173912.GU3818@linux.vnet.ibm.com>
 <20160125180234.GA26732@arm.com>
 <20160126061211.GK4503@linux.vnet.ibm.com>
In-Reply-To: <20160126061211.GK4503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orgl

On Mon, Jan 25, 2016 at 10:12:11PM -0800, Paul E. McKenney wrote:
> On Mon, Jan 25, 2016 at 06:02:34PM +0000, Will Deacon wrote:

> > Thanks for having a go at this. I tried defining something axiomatically,
> > but got stuck pretty quickly. In my scheme, I used "data-directed
> > transitivity" instead of "local transitivity", since the latter seems to
> > be a bit of a misnomer.
> 
> I figured that "local" meant local to the CPUs participating in the
> release-acquire chain.  As opposed to smp_mb() chains where the ordering
> is "global" as in visible to all CPUs, whether on the chain or not.
> Does that help?

That is in fact how I read and understood it.


