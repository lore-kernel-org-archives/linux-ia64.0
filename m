From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 15 Jan 2016 19:28:45 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160115192845.GA12510@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5696CF08.8080700@imgtec.com> <20160114121449.GC15828@arm.com>
	<5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
	<56980C91.1010403@imgtec.com>
	<20160114212913.GF3818@linux.vnet.ibm.com>
	<569814F2.50801@imgtec.com>
	<20160114225510.GJ3818@linux.vnet.ibm.com>
	<20160115102431.GB2131@arm.com>
	<20160115175401.GW3818@linux.vnet.ibm.com>
In-Reply-To: <20160115175401.GW3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.

On Fri, Jan 15, 2016 at 09:54:01AM -0800, Paul E. McKenney wrote:
> On Fri, Jan 15, 2016 at 10:24:32AM +0000, Will Deacon wrote:
> > On Thu, Jan 14, 2016 at 02:55:10PM -0800, Paul E. McKenney wrote:
> > > On Thu, Jan 14, 2016 at 01:36:50PM -0800, Leonid Yegoshin wrote:
> > > > On 01/14/2016 01:29 PM, Paul E. McKenney wrote:
> > > > >
> > > > >>On 01/14/2016 12:34 PM, Paul E. McKenney wrote:
> > > > >>>
> > > > >>>The WRC+addr+addr is OK because data dependencies are not required to be
> > > > >>>transitive, in other words, they are not required to flow from one CPU to
> > > > >>>another without the help of an explicit memory barrier.
> > > > >>I don't see any reliable way to fit WRC+addr+addr into "DATA
> > > > >>DEPENDENCY BARRIERS" section recommendation to have data dependency
> > > > >>barrier between read of a shared pointer/index and read the shared
> > > > >>data based on that pointer. If you have this two reads, it doesn't
> > > > >>matter the rest of scenario, you should put the dependency barrier
> > > > >>in code anyway. If you don't do it in WRC+addr+addr scenario then
> > > > >>after years it can be easily changed to different scenario which
> > > > >>fits some of scenario in "DATA DEPENDENCY BARRIERS" section and
> > > > >>fails.
> > > > >The trick is that lockless_dereference() contains an
> > > > >smp_read_barrier_depends():
> > > > >
> > > > >#define lockless_dereference(p) \
> > > > >({ \
> > > > >	typeof(p) _________p1 = READ_ONCE(p); \
> > > > >	smp_read_barrier_depends(); /* Dependency order vs. p above. */ \
> > > > >	(_________p1); \
> > > > >})
> > > > >
> > > > >Or am I missing your point?
> > > > 
> > > > WRC+addr+addr has no any barrier. lockless_dereference() has a
> > > > barrier. I don't see a common points between this and that in your
> > > > answer, sorry.
> > > 
> > > Me, I am wondering what WRC+addr+addr has to do with anything at all.
> > 
> > See my earlier reply [1] (but also, your WRC Linux example looks more
> > like a variant on WWC and I couldn't really follow it).
> 
> I will revisit my WRC Linux example.  And yes, creating litmus tests
> that use non-fake dependencies is still a bit of an undertaking.  :-/
> I am sure that it will seem more natural with time and experience...

Hmmm...  You are quite right, I did do WWC.  I need to change cpu2()'s
last access from a store to a load to get WRC.  Plus the levels of
indirection definitely didn't match up, did they?

	struct foo {
		struct foo *next;
	};
	struct foo a;
	struct foo b;
	struct foo c = { &a };
	struct foo d = { &b };
	struct foo x = { &c };
	struct foo y = { &d };
	struct foo *r1, *r2, *r3;

	void cpu0(void)
	{
		WRITE_ONCE(x.next, &y);
	}

	void cpu1(void)
	{
		r1 = lockless_dereference(x.next);
		WRITE_ONCE(r1->next, &x);
	}

	void cpu2(void)
	{
		r2 = lockless_dereference(y.next);
		r3 = READ_ONCE(r2->next);
	}

In this case, it is legal to end the run with:

	r1 = &y && r2 = &x && r3 = &c

Please see below for a ppcmem litmus test.

So, did I get it right this time?  ;-)

							Thanx, Paul

PS.  And yes, working through this does help me understand the
     benefits of fake dependencies.  Why do you ask?  ;-)

------------------------------------------------------------------------

PPC WRCnf+addrs
""
{
0:r2=x; 0:r3=y;
1:r2=x; 1:r3=y;
2:r2=x; 2:r3=y;
c=a; d=b; x=c; y=d;
}
 P0           | P1            | P2            ;
 stw r3,0(r2) | lwz r8,0(r2)  | lwz r8,0(r3)  ;
              | stw r2,0(r3)  | lwz r9,0(r8)  ;
exists
(1:r8=y /\ 2:r8=x /\ 2:r9=c)

