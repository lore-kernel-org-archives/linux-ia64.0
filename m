From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 24 Oct 2006 21:24:23 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <1161725063.22348.39.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com>
In-Reply-To: <adafyddcysw.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

Ar Maw, 2006-10-24 am 12:13 -0700, ysgrifennodd Roland Dreier:
>  1) Is this something that should be fixed in the driver?  The PCI
>     spec allows MMIO cycles to start before an earlier config cycle
>     completed, but do we want to expose this fact to drivers?  Would
>     it be better for ia64 to use some sort of barrier to make sure
>     pci_write_config_xxx() is strongly ordered with MMIO?

It is good to be conservative in this area. Some AMD chipsets at least
had ordering problems with some configurations in the K7 era.


