From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 19:40:36 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008272140.37453.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com> <201008271916.30369.ptesarik@suse.cz>
In-Reply-To: <201008271916.30369.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

On Friday 27 of August 2010 19:16:29 Petr Tesarik wrote:
> On Friday 27 of August 2010 18:08:03 Luck, Tony wrote:
> > > Hedi Berriche sent me a simple test case that can
> > > trigger the failure on the siglock.
> >
> > Can you post the test case please. How long does it typically take
> > to reproduce the problem?
>
> I let Hedi send it. It's really easy to reproduce. In fact, I can reproduce
> it within 5 minutes on an 8-CPU system.
>
> > > Next, CPU 5 releases the spinlock with st2.rel, changing the lock
> > > value to 0x0 (correct).
> > >
> > > SO FAR SO GOOD.
> > >
> > > Now, CPU 4, CPU 5 and CPU 7 all want to acquire the lock again.
> > > Interestingly, CPU 5 and CPU 7 are both granted the same ticket,
> >
> > What is the duplicate ticket number that CPUs 5 & 7 get at this point?
> > Presumably 0x0, yes? Or do they see a stale 0x7fff?
>
> They get a zero, yes.
>
> > > and the spinlock value (as seen from the debug fault handler) is
> > > 0x0 after single-stepping over the fetchadd4.acq, in both cases.
> > > CPU 4 correctly sets the spinlock value to 0x1.
> >
> > Is the fault handler using "ld.acq" to look at the spinlock value?
> > If not, then this might be a red herring. [Though clearly something
> > bad is going on here].
>
> Right. I also realized I was reading the spinlock value with a plain "ld4".
> When I changed it to "ld4.acq", this is what happens:
>
> 1. We're in _spin_lock_irq, which starts like this:
>
> 0xa0000001008ea000 <_spin_lock_irq>:    [MMI]       rsm 0x4000;;
> 0xa0000001008ea001 <_spin_lock_irq+1>:              fetchadd4.acq
> r15=[r32],1 0xa0000001008ea002 <_spin_lock_irq+2>:              nop.i 0x0;;
>
> AFAICS the spinlock value should be 0x0 (after having wrapped around from
> 0xffff0000 at release on the same CPU).
>
> 2. fetchadd4.acq generates a debug exception (because it writes to the
> watched location)
> 3. ld4.acq inside the debug fault handler reads 0x0 from the location
> 4. the handler sets PSR.ss on return
> 5. fetchadd4.acq puts 0x1 (why?) in r15 and generates a Single step fault
> 6. the fault handler now reads 0x0 (sic!) from the spinlock location
> (again, using ld4.acq)
> 7. the resulting kernel crash dump contains ZERO in the spinlock location

I have another crash dump which recorded the same values in the debug fault 
handler, but the resulting crash dump contains 0x1 (not 0x0) in the spinlock. 
R15 was still 0x1 (even though it should contain the original value, not the 
incremented one, shouldn't it?).

Petr Tesarik
