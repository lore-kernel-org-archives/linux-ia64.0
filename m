From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 04 May 2004 23:23:24 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <1083713004.5669.24.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-05-04 at 17:17, Jesse Barnes wrote:

> > ISTR only config space accesses are always required to softfail
> > on master aborts. I don't recall if IO Port space is required to as
> > well and it looks like this issue is outside the scope of PCI spec.
> 
> Alex says that zx1 can soft fail on IO port accesses if configured to do so.  
> We don't have that option.
> 

   And the default configuration for zx1 is I/O port space in soft fail,
MMIO space in hardfail.  The current zx1 "smarts" in X can reconfigure
the bridge w/ VGA to softfail MMIO for probing/int10 support.  It's
ugly, but it works.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

