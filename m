From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 26 Jan 2016 19:58:20 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126195820.GS4503@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <56980C91.1010403@imgtec.com>
 <20160114212913.GF3818@linux.vnet.ibm.com>
 <20160115085554.GF3421@worktop>
 <20160115091348.GA27936@worktop>
 <20160115174612.GV3818@linux.vnet.ibm.com>
 <20160115212714.GM3421@worktop>
 <20160115215853.GC3818@linux.vnet.ibm.com>
 <20160125164242.GF22927@arm.com>
 <20160126060322.GJ4503@linux.vnet.ibm.com>
 <20160126121608.GE21553@arm.com>
In-Reply-To: <20160126121608.GE21553-5wv7dgnIgG8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Leonid Yegoshin <Leonid.Yegoshin-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5ug@public.gmane.org

On Tue, Jan 26, 2016 at 12:16:09PM +0000, Will Deacon wrote:
> On Mon, Jan 25, 2016 at 10:03:22PM -0800, Paul E. McKenney wrote:
> > On Mon, Jan 25, 2016 at 04:42:43PM +0000, Will Deacon wrote:
> > > On Fri, Jan 15, 2016 at 01:58:53PM -0800, Paul E. McKenney wrote:
> > > > PPC Overlapping Group-B sets version 4
> > > > ""
> > > > (* When the Group-B sets from two different barriers involve instructions in
> > > >    the same thread, within that thread one set must contain the other.
> > > > 
> > > > 	P0	P1	P2
> > > > 	Rx=1	Wy=1	Wz=2
> > > > 	dep.	lwsync	lwsync
> > > > 	Ry=0	Wz=1	Wx=1
> > > > 	Rz=1
> > > > 
> > > > 	assert(!(z=2))
> > > > 
> > > >    Forbidden by ppcmem, allowed by herd.
> > > > *)
> > > > {
> > > > 0:r1=x; 0:r2=y; 0:r3=z;
> > > > 1:r1=x; 1:r2=y; 1:r3=z; 1:r4=1;
> > > > 2:r1=x; 2:r2=y; 2:r3=z; 2:r4=1; 2:r5=2;
> > > > }
> > > >  P0		| P1		| P2		;
> > > >  lwz r6,0(r1)	| stw r4,0(r2)	| stw r5,0(r3)	;
> > > >  xor r7,r6,r6	| lwsync	| lwsync	;
> > > >  lwzx r7,r7,r2	| stw r4,0(r3)	| stw r4,0(r1)	;
> > > >  lwz r8,0(r3)	|		|		;
> > > > 
> > > > exists
> > > > (z=2 /\ 0:r6=1 /\ 0:r7=0 /\ 0:r8=1)
> > > 
> > > That really hurts. Assuming that the "assert(!(z=2))" is actually there
> > > to constrain the coherence order of z to be {0->1->2}, then I think that
> > > this test is forbidden on arm using dmb instead of lwsync. That said, I
> > > also don't think the Rz=1 in P0 changes anything.
> > 
> > What about the smp_wmb() variant of dmb that orders only stores?
> 
> Tricky, but I think it still works out if the coherence order of z is as
> I described above. The line of reasoning is weird though -- I ended up
> considering the two cases where P0 reads z before and after it reads x
> and what that means for the read of y.

By "works out" you mean that ARM prohibits the outcome?

BTW, I never have seen a real-world use for this case.  At the moment
it is mostly a cautionary tale about memory-model corner cases and
tools.

							Thanx, Paul

