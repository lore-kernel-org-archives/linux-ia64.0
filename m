From: "John Lee" <jlee@platsolns.com>
Date: Fri, 30 Apr 2004 22:06:15 +0000
Subject: RE: SAL PCI config space
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E4BEE32@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com] 
> Sent: Friday, April 30, 2004 2:59 PM
> To: Grant Grundler; John Lee
> Cc: Matthew Wilcox; linux-ia64@vger.kernel.org
> Subject: RE: SAL PCI config space
> 
> >> Multiple OSs/executables on different Soft partitions do not share
> >> others' lock variables, unless otherwise all SAL calls of soft
> >> partitions are redirected to one hosting OS, which sounds not
> >> reasonable.
> >
> >Yes. I think that's why the SAL spec changed because all the vendors
> >want to support virtual machines.
> >But that doesn't help the older boxes which do not implement
> >the newer SAL spec or have "non-compliant" implementations.
> 
> There would be other issues besides whether some SAL calls
> are re-entrant to running multiple OS in soft partitions. E.g.
> MCA

I'm already there. RAS for soft partitions ;)
Any forum or discussion on that front would be helpful if you could
invite us.

Thanks,
John Lee
