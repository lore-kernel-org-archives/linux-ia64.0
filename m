From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 24 Oct 2006 19:22:10 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061024192210.GE2043@havoc.gtf.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com>
In-Reply-To: <adafyddcysw.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

On Tue, Oct 24, 2006 at 12:13:19PM -0700, Roland Dreier wrote:
>  1) Is this something that should be fixed in the driver?  The PCI
>     spec allows MMIO cycles to start before an earlier config cycle
>     completed, but do we want to expose this fact to drivers?  Would
>     it be better for ia64 to use some sort of barrier to make sure
>     pci_write_config_xxx() is strongly ordered with MMIO?

The PCI config APIs have traditionally enforced very strong ordering.
Heck, the PCI config APIs often take a spinlock on each read or write;
so they are definitely not intended to be as fast as MMIO.

	Jeff



