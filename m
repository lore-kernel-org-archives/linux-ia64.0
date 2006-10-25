From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 25 Oct 2006 14:04:56 +0000
Subject: Re: [openib-general] Ordering between PCI config space writes and MMIO reads?
Message-Id: <adairi8biev.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org>
	<20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com>
	<20061024223631.GT25210@parisc-linux.org>
	<20061024225935.GK4054@obsidianresearch.com>
In-Reply-To: <20061024225935.GK4054@obsidianresearch.com> (Jason Gunthorpe's message of "Tue, 24 Oct 2006 16:59:35 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-ia64@vger.kernel.org, Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz

 > I'm not sure that can work either. The PCI-X spec is very clear, you
 > must wait for a non-posted completion if you care about order. Doing a
 > config read in the driver as a surrogate flush is not good enough in
 > the general case. Like you say, a pci bridge is free to reorder all
 > in flight non-posted operations.

No, hang on.  Nothing can reorder a dependent read to start after a
write that it depends on, can it?  So a config read of PCI_COMMAND
can't start until the completion of a config write of the same
register, right?

 - R.
