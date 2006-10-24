From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 24 Oct 2006 21:29:47 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <aday7r5bdx0.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com>
	<1161725063.22348.39.camel@localhost.localdomain>
In-Reply-To: <1161725063.22348.39.camel@localhost.localdomain> (Alan Cox's message of "Tue, 24 Oct 2006 22:24:23 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

 > It is good to be conservative in this area. Some AMD chipsets at least
 > had ordering problems with some configurations in the K7 era.

Could you expand a little?  Do you mean that the arch implementation
of pci_write_config_xxx() should have extra barriers, or that drivers
should do belt-and-suspenders flushes to make sure config writes are
really done properly?

 - R.
