From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 01 Nov 2006 17:14:44 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061101171443.GI11399@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024.154347.77057163.davem@davemloft.net> <aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com> <20061031195312.GD5950@mellanox.co.il> <019301c6fd2c$044d7010$0732700a@djlaptop> <20061031204717.GG26964@parisc-linux.org> <ada4ptkt8y2.fsf@cisco.com> <4548CAE7.8010300@sgi.com> <20061101164643.GH11399@parisc-linux.org> <4548D478.2080704@sgi.com>
In-Reply-To: <4548D478.2080704@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Partridge <johnip@sgi.com>
Cc: Roland Dreier <rdreier@cisco.com>, "Richard B. Johnson" <jmodem@AbominableFirebug.com>, "Michael S. Tsirkin" <mst@mellanox.co.il>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

On Wed, Nov 01, 2006 at 11:08:08AM -0600, John Partridge wrote:
> So, if I understand correctly, you are saying because we cannot guarantee
> the "flush" a config write even by doing a config read of the same register
> (because the PPB can re-order) we have to make sure we block or spin on the
> config write completion at the lowest level of the config write ?

That's correct.  And I'm also saying that the reason this hasn't
been thought about before is that other root bridges have a mechanism
(implicit on x86, explicit on parisc) for waiting for the config write
completion to come back.

Seems to me that Altix uses the SAL calls to access PCI config space
these days, so you can hide it in your firmware rather than patching
Linux.
