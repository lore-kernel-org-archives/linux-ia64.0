From: Grant Grundler <iod00d@hp.com>
Date: Fri, 30 Apr 2004 21:45:39 +0000
Subject: Re: SAL PCI config space
Message-Id: <20040430214539.GD7872@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 30, 2004 at 01:27:14PM -0700, John Lee wrote:
> Most of the SAL calls except the pure reading ones w/o affecting any
> state have to be reentrant and MP safe, don't they?
> Multiple OSs/executables on different Soft partitions do not share
> others' lock variables, unless otherwise all SAL calls of soft
> partitions are redirected to one hosting OS, which sounds not
> reasonable.

Yes. I think that's why the SAL spec changed because all the vendors
want to support virtual machines.
But that doesn't help the older boxes which do not implement
the newer SAL spec or have "non-compliant" implementations.

> So, SAL_CALL_REENTRANT could be a solution for the kernel itself, but
> not for partitioned platforms.

Sorry - this statement doesn't make sense to me.
You meant s/SAL_CALL_REENTRANT/spinlocks/ above maybe?

grant

> 
> Thanks,
> John
>  
> 
> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
> Sent: Friday, April 30, 2004 1:09 PM
> To: Matthew Wilcox
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: SAL PCI config space
> 
> >So what's actually shipping in systems?  David's against runtime checks
> >due to some of the buggy firmware hp's managed to ship.  I agree with
> >him that it would have been much more sensible had the SAL 
> >spec specifid new calls rather than changing the semantics of existing
> calls.
> 
> It's not whats shipping that's the big problem ... it's the people
> still running BigSur, Lion and other prototype systems that will
> never have their firmware upgraded to SAL3.2 spec.
> 
> Apart from general cleanliness of not having functions that are
> re-entrant and MP safe uselessly spin on a lock to serialize, do
> you see any tangible benefits from switching these to use the
> SAL_CALL_REENTRANT method?  Surely config space accesses aren't
> in anyone's critical path?
> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
