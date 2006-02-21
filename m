From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 21 Feb 2006 08:03:14 +0000
Subject: Re: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <1140508994.3082.16.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214162337.GA16954@sgi.com>
	 <20060220201713.GA4992@infradead.org>  <20060221024710.GB30226@sgi.com>
In-Reply-To: <20060221024710.GB30226@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 2006-02-20 at 20:47 -0600, Mark Maule wrote:
> On Mon, Feb 20, 2006 at 08:17:14PM +0000, Christoph Hellwig wrote:
> > On Tue, Feb 14, 2006 at 10:23:37AM -0600, Mark Maule wrote:
> > > Export sn_pcidev_info_get.
> > 
> > Tony or Andrew please back this out again.  The only reason SGI wants this is
> > to support their illegal graphics driver, and no core code uses it.
> > 
> > And Mark, please stop submitting such patches.
> 
> All I'm doing by exporting sn_pcidev_info_get is allowing a module to use
> the SGI SN_PCIDEV_BUSSOFT() macro which will tell a driver which piece of
> altix PCI hw its device is sitting behind (e.g. PCIIO_ASIC_TYPE_TIOCP et. al).
> 
> While I acknowledge that the gfx driver folks requested this, I don't
> understand what is "illegal" about this export, or the driver which wants
> to use it.  What am I missing here?

so you would have no objection to making this a _GPL export ?


