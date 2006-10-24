From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 24 Oct 2006 21:37:44 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061024213744.GH2043@havoc.gtf.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <1161725063.22348.39.camel@localhost.localdomain> <aday7r5bdx0.fsf@cisco.com>
In-Reply-To: <aday7r5bdx0.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

On Tue, Oct 24, 2006 at 02:29:47PM -0700, Roland Dreier wrote:
>  > It is good to be conservative in this area. Some AMD chipsets at least
>  > had ordering problems with some configurations in the K7 era.
> 
> Could you expand a little?  Do you mean that the arch implementation
> of pci_write_config_xxx() should have extra barriers, or that drivers
> should do belt-and-suspenders flushes to make sure config writes are
> really done properly?

Drivers are -already- written to assume the pci_write_config_xxx() has
the requisite barriers.  The fix doesn't belong in the drivers.

	Jeff



