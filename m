From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 24 Oct 2006 21:51:30 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <adar6wxbcwt.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org>
	<20061024214724.GS25210@parisc-linux.org>
In-Reply-To: <20061024214724.GS25210@parisc-linux.org> (Matthew Wilcox's message of "Tue, 24 Oct 2006 15:47:24 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Jeff Garzik <jeff@garzik.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

 > I think the right way to fix this is to ensure mmio write ordering in
 > the pci_write_config_*() implementations.  Like this.

I'm happy to fix this in the PCI core and not force drivers to worry
about this.

John, can you confirm that this patch fixes the issue for you?

Thanks,
  Roland
