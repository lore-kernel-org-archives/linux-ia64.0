From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 25 Feb 2006 11:55:26 +0000
Subject: Re: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <20060225115526.GB24439@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214162337.GA16954@sgi.com> <20060220201713.GA4992@infradead.org> <20060220133956.01b59562.akpm@osdl.org> <20060221104841.GE19349@infradead.org>
In-Reply-To: <20060221104841.GE19349@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, maule@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 21, 2006 at 10:48:41AM +0000, Christoph Hellwig wrote:
> On Mon, Feb 20, 2006 at 01:39:56PM -0800, Andrew Morton wrote:
> > Christoph Hellwig <hch@infradead.org> wrote:
> > >
> > >  On Tue, Feb 14, 2006 at 10:23:37AM -0600, Mark Maule wrote:
> > >  > Export sn_pcidev_info_get.
> > > 
> > >  Tony or Andrew please back this out again.
> > 
> > Please send a patch.

ping?

> --- a/arch/ia64/sn/kernel/io_init.c	20 Feb 2006 14:29:08 -0000	1.11
> +++ b/arch/ia64/sn/kernel/io_init.c	21 Feb 2006 10:47:10 -0000
> @@ -716,4 +716,3 @@ EXPORT_SYMBOL(sn_pci_unfixup_slot);
>  EXPORT_SYMBOL(sn_pci_controller_fixup);
>  EXPORT_SYMBOL(sn_bus_store_sysdata);
>  EXPORT_SYMBOL(sn_bus_free_sysdata);
> -EXPORT_SYMBOL(sn_pcidev_info_get);
---end quoted text---
