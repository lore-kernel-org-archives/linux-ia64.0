From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 26 Feb 2008 01:11:39 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:
Message-Id: <1203988299.4997.6.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 2008-02-25 at 16:08 -0700, Alex Chiang wrote:
> * Bjorn Helgaas <bjorn.helgaas@hp.com>:
> > On Friday 22 February 2008 12:28:26 am Shaohua Li wrote:
> > > My tiger machine hangs since 2.6.23 with commit above. I always saw oops
> > > in ia64_sal_physical_id_info(). In 2.6.22, if ia64_pal_logical_to_phys
> > > returns UNIMPLENTED, ia64_sal_physical_id_info() isn't called. Below
> > > patch fixes the issue. 
> > 
> > I added a descriptive subject and copied the author of the change.
> > He's been travelling for a month or so and might not be able to respond
> > immediately.
> 
> Thanks Bjorn.
> 
> > > diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
> > > index 32ee597..6e0290b 100644
> > > --- a/arch/ia64/kernel/smpboot.c
> > > +++ b/arch/ia64/kernel/smpboot.c
> > > @@ -878,13 +878,10 @@ identify_siblings(struct cpuinfo_ia64 *c)
> > >  			printk(KERN_ERR
> > >  				"ia64_pal_logical_to_phys failed with %ld\n",
> > >  				status);
> > > -			return;
> > >  		}
> > > -
> > > -		info.overview_ppid = 0;
> > > -		info.overview_cpp  = 1;
> > > -		info.overview_tpc  = 1;
> > > +		return;
> 
> My original commit relied on fall-through behavior to still try
> and call ia64_sal_physical_id_info(), because there are
> cases/platforms where PAL_LOGICAL_TO_PHYSICAL is not implemented
> but SAL_PHYSICAL_ID_INFO is.
> 
> I think the more interesting question is, why is that SAL call
> hanging / oops'ing your machine rather than returning with an
> error code?
> 
> In other words, why doesn't the error path work?
Yes, this is strange. But other SAL calls are ok, maybe firmware bug or
something I don't know. I'm not familiar with this area, if you need
further info, let me know.

Thanks,
Shaohua

