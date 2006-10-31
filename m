From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 31 Oct 2006 22:30:13 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <ada4ptkt8y2.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org>
	<adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org>
	<20061024.154347.77057163.davem@davemloft.net>
	<aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com>
	<20061031195312.GD5950@mellanox.co.il>
	<019301c6fd2c$044d7010$0732700a@djlaptop>
	<20061031204717.GG26964@parisc-linux.org>
In-Reply-To: <20061031204717.GG26964@parisc-linux.org> (Matthew Wilcox's message of "Tue, 31 Oct 2006 13:47:17 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>, John Partridge <johnip@sgi.com>
Cc: "Richard B. Johnson" <jmodem@AbominableFirebug.com>, "Michael S. Tsirkin" <mst@mellanox.co.il>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

 > I'm beginning to think Michael Tsirkin has the only solution to this
 > -- architectures need to check that their hardware blocks until the
 > config write completion has occurred (and if not, simulate that it has
 > in software).

OK, I guess I'm convinced.  The vague language in the base PCI 3.0
spec about "dependencies" made me think that a read of a config
register had to wait until all previous writes to the same register
are done.  So I'll drop this patch for now.

John, you'll need to try and come up with a way to solve this in the
Altix implementation of pci_write_config_xxx().

 - R.
