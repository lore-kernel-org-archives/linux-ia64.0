From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 25 Oct 2006 14:15:16 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <aday7r4a3d7.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org>
	<adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org>
	<20061024.154347.77057163.davem@davemloft.net>
In-Reply-To: <20061024.154347.77057163.davem@davemloft.net> (David Miller's message of "Tue, 24 Oct 2006 15:43:47 -0700 (PDT)")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: matthew@wil.cx, jeff@garzik.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, johnip@sgi.com

 > One thing is that we definitely don't want to fix this by,
 > for example, reading back the PCI_COMMAND register or something
 > like that.  That causes two problems:
 > 
 > 1) Some PCI config writes shut the device down and make it
 >    no respond to some kinds of PCI config transactions.
 >    One example is putting the device into D3 or similar
 >    power state, another is performing a device reset.

Hmm... it seems there is no other guaranteed way to make sure a config
write has really completed except doing a config read.  And only the
driver knows what the config access it's doing means.  So the
conclusion we seem to be forced into is that drivers need to include
these reads in the cases where they are needed.

 - R.
