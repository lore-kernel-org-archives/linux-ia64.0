From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Tue, 24 Oct 2006 23:09:08 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061024230908.GB13022@mellanox.co.il>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org> <20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org>
In-Reply-To: <20061024223631.GT25210@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Roland Dreier <rdreier@cisco.com>, linux-ia64@vger.kernel.org, Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz

Quoting r. Matthew Wilcox <matthew@wil.cx>:
> Subject: Re: Ordering between PCI config space writes and MMIO reads?
> 
> On Tue, Oct 24, 2006 at 02:51:30PM -0700, Roland Dreier wrote:
> >  > I think the right way to fix this is to ensure mmio write ordering in
> >  > the pci_write_config_*() implementations.  Like this.
> > 
> > I'm happy to fix this in the PCI core and not force drivers to worry
> > about this.
> > 
> > John, can you confirm that this patch fixes the issue for you?
> 
> Hang on.  I wasn't thinking clearly.  mmiowb() only ensures the write
> has got as far as the shub.  There's no way to fix this in the pci core
> -- any PCI-PCI bridge can reorder the two.
> 
> This is only really a problem for setup (when we program the BARs), so
> it seems silly to enforce an ordering at any other time.  Reluctantly, I
> must disagree with Jeff -- drivers need to fix this.

This can be true for any bridge.
Most arches, however, simply block until config write completes - this is why
driver doesn't issue any MMIO writes - and this is what we are looking for here
- a way to block the CPU until split completion for config write arrives.

By the way, e.g. the PCI Express spec says:
"Read Requests and I/O or Configuration Write Requests are permitted to be
blocked by or to pass other Read Requests and I/O or Configuration Write Requests."
so it is not clear that doing a config read will always flush all config writes
as you want.

-- 
MST
