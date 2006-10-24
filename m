From: John Partridge <johnip@sgi.com>
Date: Tue, 24 Oct 2006 22:12:07 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <453E8FB7.9090001@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org>	<20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com>
In-Reply-To: <adar6wxbcwt.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Jeff Garzik <jeff@garzik.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org

Roland Dreier wrote:
>  > I think the right way to fix this is to ensure mmio write ordering in
>  > the pci_write_config_*() implementations.  Like this.
> 
> I'm happy to fix this in the PCI core and not force drivers to worry
> about this.
> 
> John, can you confirm that this patch fixes the issue for you?
> 
> Thanks,
>   Roland

I'll give it a try and get back to you.

John

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
