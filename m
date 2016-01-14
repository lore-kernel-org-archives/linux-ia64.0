From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 14 Jan 2016 21:29:13 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114212913.GF3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com>
	<20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
	<56980C91.1010403@imgtec.com>
In-Reply-To: <56980C91.1010403@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux-a

On Thu, Jan 14, 2016 at 01:01:05PM -0800, Leonid Yegoshin wrote:
> I need some time to understand your test examples. However,

Understood.

> On 01/14/2016 12:34 PM, Paul E. McKenney wrote:
> >
> >
> >The WRC+addr+addr is OK because data dependencies are not required to be
> >transitive, in other words, they are not required to flow from one CPU to
> >another without the help of an explicit memory barrier.
> 
> I don't see any reliable way to fit WRC+addr+addr into "DATA
> DEPENDENCY BARRIERS" section recommendation to have data dependency
> barrier between read of a shared pointer/index and read the shared
> data based on that pointer. If you have this two reads, it doesn't
> matter the rest of scenario, you should put the dependency barrier
> in code anyway. If you don't do it in WRC+addr+addr scenario then
> after years it can be easily changed to different scenario which
> fits some of scenario in "DATA DEPENDENCY BARRIERS" section and
> fails.

The trick is that lockless_dereference() contains an
smp_read_barrier_depends():

#define lockless_dereference(p) \
({ \
	typeof(p) _________p1 = READ_ONCE(p); \
	smp_read_barrier_depends(); /* Dependency order vs. p above. */ \
	(_________p1); \
})

Or am I missing your point?

> >   Transitivity is
> 
> Peter Zijlstra recently wrote: "In particular we're very much all
> 'confused' about the various notions of transitivity". I am confused
> too, so - please use some more simple way to explain your words.
> Sorry, but we need a common ground first.

OK, how about an example?  (Z6.3 in the ppcmem naming scheme.)

	int x, y, z;

	void cpu0(void)
	{
		WRITE_ONCE(x, 1);
		smp_wmb();
		WRITE_ONCE(y, 1);
	}

	void cpu1(void)
	{
		WRITE_ONCE(y, 2);
		smp_wmb();
		WRITE_ONCE(z, 1);
	}

	void cpu2(void)
	{
		r1 = READ_ONCE(z);
		smp_rmb();
		r2 = read_once(x);
	}

If smp_rmb() and smp_wmb() provided transitive ordering, then cpu2()
would see cpu0()'s ordering.  But they do not, so the ordering is
visible at best to the adjacent CPU.  This means that the final value
of y can be 2, while at the same time r1=1 && r2=0.

Now the full barrier, smp_mb(), does provide transitive ordering,
so if the three barriers in the above example are replaced with
smp_mb() the y=2 && r1=1 && r2=0 outcome will be prohibited.

So smp_mb() provides transitivity, as do pairs of smp_store_release()
and smp_read_acquire(), as do RCU grace periods.  The exact interactions
between transitive and non-transitive ordering is a work in progress.
That said, if a series of transitive segments ends in a write, which
connects to a single non-transitive segment starting with a read,
you should be good.  And in fact in the example above, you can replace
the smp_wmb()s with smp_mb() and leave the smp_rmb() and still
prohibit the "cyclic" outcome.

If you want a more formal definition, I must refer you back to the
ppcmem and herd references.

Does that help?

							Thanx, Paul

