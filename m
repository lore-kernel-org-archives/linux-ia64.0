From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 14 Jan 2016 20:34:30 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114203430.GC3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <56945366.2090504@imgtec.com>
	<20160112092711.GP6344@twins.programming.kicks-ass.net>
	<20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com>
	<20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com>
In-Reply-To: <5697F6D2.60409@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux-a

On Thu, Jan 14, 2016 at 11:28:18AM -0800, Leonid Yegoshin wrote:
> On 01/14/2016 04:14 AM, Will Deacon wrote:
> >On Wed, Jan 13, 2016 at 02:26:16PM -0800, Leonid Yegoshin wrote:
> >
> >>     Moreover, there are voices against guarantee that it will be in future
> >>and that voices point me to Documentation/memory-barriers.txt section "DATA
> >>DEPENDENCY BARRIERS" examples which require SYNC_RMB between loading
> >>address/index and using that for loading data based on that address or index
> >>for shared data (look on CPU2 pseudo-code):
> >>>To deal with this, a data dependency barrier or better must be inserted
> >>>between the address load and the data load:
> >>>
> >>>        CPU 1                 CPU 2
> >>>        ========       =======> >>>        { A = 1, B = 2, C = 3, P = &A, Q = &C }
> >>>        B = 4;
> >>>        <write barrier>
> >>>        WRITE_ONCE(P, &B);
> >>>                              Q = READ_ONCE(P);
> >>>                              <data dependency barrier> <-----------
> >>>SYNC_RMB is here
> >>>                              D = *Q;
> >>...
> >>>Another example of where data dependency barriers might be required is
> >>>where a
> >>>number is read from memory and then used to calculate the index for an
> >>>array
> >>>access:
> >>>
> >>>        CPU 1                 CPU 2
> >>>        ========       =======> >>>        { M[0] = 1, M[1] = 2, M[3] = 3, P = 0, Q = 3 }
> >>>        M[1] = 4;
> >>>        <write barrier>
> >>>        WRITE_ONCE(P, 1);
> >>>                              Q = READ_ONCE(P);
> >>>                              <data dependency barrier> <------------
> >>>SYNC_RMB is here
> >>>                              D = M[Q];
> >>That voices say that there is a legitimate reason to relax HW here for
> >>performance if SYNC_RMB is needed anyway to work with this sequence of
> >>shared data.
> >Are you saying that MIPS needs to implement [smp_]read_barrier_depends?
> 
> It is not me, it is Documentation/memory-barriers.txt from kernel sources.
> 
> HW team can't work on voice statements, it should do a work on
> written documents. If that is written (see above the lines which I
> marked by "SYNC_RMB") then anybody should use it and never mind how
> many CPUs/Threads are in play. This examples explicitly requires to
> insert "data dependency barrier" between reading a shared
> pointer/index and using it to fetch a shared data. So, your
> WRC+addr+addr test is a violation of that recommendation.

Perhaps Documentation/memory-barriers.txt needs additional clarification.
It would not be the first time.

If your CPU implicitly maintains ordering based on address and
data dependencies, then you don't need any instructions for
<data dependency barrier>.

The WRC+addr+addr is OK because data dependencies are not required to be
transitive, in other words, they are not required to flow from one CPU to
another without the help of an explicit memory barrier.  Transitivity is
instead supplied by smp_mb() and by smp_store_release()-smp_load_acquire()
chains.  Here is the Linux kernel code for WRC+addr+addr, give or take
(and no, I have no idea why anyone would want to write code like this):

	struct foo {
		struct foo **a;
	};
	struct foo b;
	struct foo c;
	struct foo d;
	struct foo e;
	struct foo f = { &d };
	struct foo g = { &e };
	struct foo *x = &b;

	void cpu0(void)
	{
		WRITE_ONCE(x, &f);
	}

	void cpu1(void)
	{
		struct foo *p;

		p = lockless_dereference(x);
		WRITE_ONCE(p->a, &x);
	}

	void cpu2(void)
	{
		r1 = lockless_dereference(f.a);
		WRITE_ONCE(*r1, &c);
	}

It is legal to end the run with x=&f and r1=&x.  To prevent this outcome,
we do the following:

	struct foo {
		struct foo **a;
	};
	struct foo b;
	struct foo c;
	struct foo d;
	struct foo e;
	struct foo f = { &d };
	struct foo g = { &e };
	struct foo *x = &b;

	void cpu0(void)
	{
		WRITE_ONCE(x, &f);
	}

	void cpu1(void)
	{
		struct foo *p;

		p = lockless_dereference(x);
		smp_store_release(&p->a, &x); /* Additional ordering. */
	}

	void cpu2(void)
	{
		r1 = lockless_dereference(f.a);
		WRITE_ONCE(*r1, &c);
	}

And I still don't know why anyone would need this sort of code.  ;-)

Alternatively, we pull cpu2() into cpu1():

	struct foo {
		struct foo **a;
	};
	struct foo b;
	struct foo c;
	struct foo d;
	struct foo e;
	struct foo f = { &d };
	struct foo g = { &e };
	struct foo *x = &b;

	void cpu0(void)
	{
		WRITE_ONCE(x, &f);
	}

	void cpu1(void)
	{
		struct foo *p;

		p = lockless_dereference(x);
		WRITE_ONCE(p->a, &x);
		r1 = lockless_dereference(f.a);
		WRITE_ONCE(*r1, &c);
	}

The ordering is now enforced by being within a single thread.  In fact,
the second lockless_dereference() can be READ_ONCE().

So, does MIPS maintain ordering within a given CPU based on address and
data dependencies?  If so, you don't need to emit memory-barrier instructions
for read_barrier_depends().

							Thanx, Paul

