From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 30 Jun 2004 18:11:04 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406301111.04482.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 11:19 am, Chen, Kenneth W wrote:
> Jesse Barnes wrote on Tuesday, June 29, 2004 11:14 AM
>
> > > > > > I tried both of these on a machine that doesn't have memory at
> > > > > > the stock kernel load address, and it failed very early on. 
> > > > > > However, it works with the attached patch.
> > > > >
> > > > > Let me confirm what I understand:
> > > > > David's bk tree doesn't boot.
> > > > > David's bk tree + 2 patches I posted this morning doesn't boot.
> > > > >
> > > > > Is that correct?
> > > >
> > > > Correct.  David's tree hangs at a later point though, after printing
> > > > "Console: ... 80x25".
> > >
> > > I presume David's bk tree plus this patch also hung on your machine?
> > > http://www.gelato.unsw.edu.au/linux-ia64/0406/10162.html
> >
> > Yep.  It gets as far as David's tree plus your patches from this morning.
>
> Looks like there are more places where kernel does "virt -> phys -> virt".
> And conversion from phys to virt is setting 3 msb to 1.

Yep, that looks like a problem.  The kernel hangs right after the 
local_flush_tlb_all in ia64_tlb_init, and if I comment it out I get a "Unable 
to handle kernel paging request at virtual address a000003004289f70" which, 
on sn2, looks like a virt -> phys -> virt conversion (i.e. 0x3004289f70 is a 
valid physical address).

Jesse
