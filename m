From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 23:17:30 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041617.30080.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 4:11 pm, Grant Grundler wrote:
> On Tue, May 04, 2004 at 03:36:13PM -0700, Jesse Barnes wrote:
> > Are you describing ia64 as a broken platform here?  The problem I'm
> > trying to solve isn't sn2 specific (though part of the X stuff I have to
> > do will be driven by sn2 requirements), it's a generic way to deal with
> > hard fails on PIO reads, which afaik, affects all ia64 platforms. 
> > Correct me if I'm wrong here...
>
> hardfail vs softfail is a chipset, not arch issue.
> Intel IA32/IA64 chipsets will softfail on MMIO reads and IO port
> access that master abort (timeout).

That's nice (that's why I wanted a pointer to a spec--I can hand it to our hw 
guys who have been asking for it).

> HP chipsets (ZX1/SX1000) will hardfail - it's one of the differences
> I point out in the "Porting drivers to ZX1" OLS2002 paper I wrote.
> Sounds like SGI chipsets behave the same way.

Yep.

> ISTR only config space accesses are always required to softfail
> on master aborts. I don't recall if IO Port space is required to as
> well and it looks like this issue is outside the scope of PCI spec.

Alex says that zx1 can soft fail on IO port accesses if configured to do so.  
We don't have that option.

And of course, the more general case of MMIO accesses by user level drivers 
remains...

Thanks,
Jesse
