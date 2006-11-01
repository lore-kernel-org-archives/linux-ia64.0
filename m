From: John Partridge <johnip@sgi.com>
Date: Wed, 01 Nov 2006 16:27:19 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <4548CAE7.8010300@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org>	<adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org>	<20061024.154347.77057163.davem@davemloft.net>	<aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com>	<20061031195312.GD5950@mellanox.co.il>	<019301c6fd2c$044d7010$0732700a@djlaptop>	<20061031204717.GG26964@parisc-linux.org> <ada4ptkt8y2.fsf@cisco.com>
In-Reply-To: <ada4ptkt8y2.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: Matthew Wilcox <matthew@wil.cx>, "Richard B. Johnson" <jmodem@AbominableFirebug.com>, "Michael S. Tsirkin" <mst@mellanox.co.il>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

Roland Dreier wrote:
>  > I'm beginning to think Michael Tsirkin has the only solution to this
>  > -- architectures need to check that their hardware blocks until the
>  > config write completion has occurred (and if not, simulate that it has
>  > in software).
> 
> OK, I guess I'm convinced.  The vague language in the base PCI 3.0
> spec about "dependencies" made me think that a read of a config
> register had to wait until all previous writes to the same register
> are done.  So I'll drop this patch for now.
> 
> John, you'll need to try and come up with a way to solve this in the
> Altix implementation of pci_write_config_xxx().
> 
>  - R.

Sorry, but I find this change a bit puzzling. The problem is particular to
the PPB on the HCA and not Altix. I can't see anywhere that a PCI Config Write
is required to block until completion, it is the driver and the HCA ,not the
Altix hardware that requires the Config Write to have completed before we
leave mthca_reset() Changing pci_write_config_xxx() will change the behavior
for ALL drivers and the possibility of breaking something else. The fix was
very low risk in mthca_reset(), changing the PCI code to fix this is much
more onerous.

I know you must feel like "piggy in the middle" with this, so I don't mean
to cause you any problems, but I guess I don't understand the reluctance for
the driver fix.

John

-- 
John Partridge

Silicon Graphics Inc
Tel:	651-683-3428
Vnet:	233-3428
E-Mail:	johnip@sgi.com
