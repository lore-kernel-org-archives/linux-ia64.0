From: john stultz <johnstul@us.ibm.com>
Date: Tue, 17 Jul 2007 22:50:06 +0000
Subject: Re: [PATCH 1/2] ia64 clocksource
Message-Id: <1184712606.5836.24.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2007-07-17 at 18:31 -0400, Bob Picco wrote:
> Hi:
> Thanks for the review.
> Hidetoshi Seto wrote:	[Tue Jul 17 2007, 06:55:47AM EDT]
> > Bob Picco wrote:
> > >@@ -214,61 +209,56 @@ ENTRY(fsys_gettimeofday)
> >  :
> > > 	movl r27 = xtime
> >  :
> > > .time_redo:
> > >-	.pred.rel.mutex p8,p9,p10
> > >-	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for 
> > >locking purposes
> > >+	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must be first in 
> > >struct
> >  :
> > > 	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
> >  :
> > >-	ld4 r10 = [r29]		// xtime_lock.sequence
> > >+	ld4 r10 = [r20]		// gtod_lock.sequence, old 
> > >xtime_lock.sequence
> >  :
> > > 	cmp4.ne.or p7,p0 = r28,r10
> > >-(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
> > >+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, outer 
> > >loop2
> > 
> > This patch removes locking xtime_lock but the code still reads xtime
> Well what I see is the update_vsyscall holding the xtime_lock and then
> acquiring the fsyscall_gtod_data.lock seqlock. This sequence begins in
> do_settimeofday. So the vsyscall could have a tiny window of discrepancy
> but miminal. Perhaps John can comment on this.  To me this is no
> different than x86_64 but perhaps I'm missing a subtle difference.
> > 
> > Since gtod_lock.sequence will not tell us whether xtime is updated
> > (or going to be updated) while in this window, the result may be wrong...


So w/ x86_64, we've split the xtime_lock and get vgtod_lock, so that
only when the vsyscall page is being updated do we hold a write on the
vgtod_lock. This is safe as the vsyscall gtod does not access the
kernel's time structures (xtime and friends). Instead it reads its copy
of them that is made in update_vsyscall().

So it should be fine to use the gtod_lock.sequence, assuming you're also
not touching the kernel's xtime directly  (and instead using copy of
xtime made in update_vsyscall).

Does that make sense?
-john



