From: "John Lee" <jlee@platsolns.com>
Date: Fri, 30 Apr 2004 22:03:45 +0000
Subject: RE: SAL PCI config space
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E4BEE2F@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Grant Grundler [mailto:iod00d@hp.com] 
> Sent: Friday, April 30, 2004 2:46 PM
> To: John Lee
> Cc: Luck, Tony; Matthew Wilcox; linux-ia64@vger.kernel.org
> Subject: Re: SAL PCI config space
> 
> On Fri, Apr 30, 2004 at 01:27:14PM -0700, John Lee wrote:
> > Most of the SAL calls except the pure reading ones w/o affecting any
> > state have to be reentrant and MP safe, don't they?
> > Multiple OSs/executables on different Soft partitions do not share
> > others' lock variables, unless otherwise all SAL calls of soft
> > partitions are redirected to one hosting OS, which sounds not
> > reasonable.
> 
> Yes. I think that's why the SAL spec changed because all the vendors
> want to support virtual machines.

Right. So it's SAL implementers' responsibility to make them mp-safe.

> But that doesn't help the older boxes which do not implement
> the newer SAL spec or have "non-compliant" implementations.
> 
> > So, SAL_CALL_REENTRANT could be a solution for the kernel 
> itself, but
> > not for partitioned platforms.
> 
> Sorry - this statement doesn't make sense to me.
> You meant s/SAL_CALL_REENTRANT/spinlocks/ above maybe?
> 
> grant

For Linux's own backward compatibility with older machines, I'm with
Tony - SAL_CALL_REENTRANT -, until we all agree not to worry about them.

Thanks,
John

