From: Russ Anderson <rja@sgi.com>
Date: Sun, 02 May 2004 19:21:17 +0000
Subject: SAL & partitioned systems (was: RE: SAL PCI config space)
Message-Id: <200405021921.i42JLHXA034835@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Lee wrote:
> > -----Original Message-----
> > From: Luck, Tony [mailto:tony.luck@intel.com] 
> > Sent: Friday, April 30, 2004 2:59 PM
> > To: Grant Grundler; John Lee
> > Cc: Matthew Wilcox; linux-ia64@vger.kernel.org
> > Subject: RE: SAL PCI config space
> > 
> > >> Multiple OSs/executables on different Soft partitions do not share
> > >> others' lock variables, unless otherwise all SAL calls of soft
> > >> partitions are redirected to one hosting OS, which sounds not
> > >> reasonable.
> > >
> > >Yes. I think that's why the SAL spec changed because all the vendors
> > >want to support virtual machines.
> > >But that doesn't help the older boxes which do not implement
> > >the newer SAL spec or have "non-compliant" implementations.
> > 
> > There would be other issues besides whether some SAL calls
> > are re-entrant to running multiple OS in soft partitions. E.g.
> > MCA
> 
> I'm already there. RAS for soft partitions ;)
> Any forum or discussion on that front would be helpful if you could
> invite us.

A couple quick comments ('cause I'm short on time):

The general issue of re-entrant SAL calls and SAL locks (and/or
MCA rendezvous) seems to apply to soft partitions, dynamic add/remove,
and error handling (and probably more).

Part of the issue is whether SAL should be a small, thin layer between
the OS and the hardware or whether SAL should be an "uber" OS.  The
former relies on the OS for support avoid to limitations in SAL.  The later
removes those restrictions, but moves much more complexity into SAL.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
