From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 25 Oct 2006 14:11:06 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <ada3b9cbi4l.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com>
	<20061025063022.GC12319@colo.lackof.org>
In-Reply-To: <20061025063022.GC12319@colo.lackof.org> (Grant Grundler's message of "Wed, 25 Oct 2006 00:30:22 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <grundler@parisc-linux.org>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

 > I'm looking at arch/ia64/pci/pci.c.
 > Wouldn't it be reasonable to include memory barriers around calls
 > to SAL config space access functions?

It's reasonable, but is there a memory barrier strong enough to
guarantee that a config write has actually completed?

 - R.
