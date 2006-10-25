From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 25 Oct 2006 14:05:59 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <adaejswbid4.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org>
	<20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com>
	<20061024223631.GT25210@parisc-linux.org>
	<20061024232755.GA26521@sgi.com>
In-Reply-To: <20061024232755.GA26521@sgi.com> (Jack Steiner's message of "Tue, 24 Oct 2006 18:27:55 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Jeff Garzik <jeff@garzik.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

 > I'll check if there is any additional reordering that can occur AFTER the
 > PIO_WRITE_COUNT goes to zero.  If so, it would be at bus level - not in
 > shub or routers.

Unfortunately, at least in theory, the reordering can occur.  For
example a bridge on some card plugged into an SN slot is allowed to
reorder things too.

 - R.
