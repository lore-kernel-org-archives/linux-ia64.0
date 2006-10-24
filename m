From: David Miller <davem@davemloft.net>
Date: Tue, 24 Oct 2006 22:43:47 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061024.154347.77057163.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org>
	<adar6wxbcwt.fsf@cisco.com>
	<20061024223631.GT25210@parisc-linux.org>
In-Reply-To: <20061024223631.GT25210@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: matthew@wil.cx
Cc: rdreier@cisco.com, jeff@garzik.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, johnip@sgi.com

From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 24 Oct 2006 16:36:32 -0600

> This is only really a problem for setup (when we program the BARs), so
> it seems silly to enforce an ordering at any other time.  Reluctantly, I
> must disagree with Jeff -- drivers need to fix this.

One thing is that we definitely don't want to fix this by,
for example, reading back the PCI_COMMAND register or something
like that.  That causes two problems:

1) Some PCI config writes shut the device down and make it
   no respond to some kinds of PCI config transactions.
   One example is putting the device into D3 or similar
   power state, another is performing a device reset.

2) Several drivers use PCI config space accesses to touch the
   main registers in order to workaround bugs in the PCI-X
   implementation of their chip or similar (tg3 has a few
   cases like this), doing a PCI config space readback will
   kill performance quite a bit for an already slow situation.

In fact, I do recall that one of the x86 PCI config space access
implementations did a readback like this, and we had to remove
it because it caused problems when doing a reset on tg3 chips
when using PCI config space register write to do the reset.
