From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 31 Oct 2006 20:47:17 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061031204717.GG26964@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org> <20061024.154347.77057163.davem@davemloft.net> <aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com> <20061031195312.GD5950@mellanox.co.il> <019301c6fd2c$044d7010$0732700a@djlaptop>
In-Reply-To: <019301c6fd2c$044d7010$0732700a@djlaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Richard B. Johnson" <jmodem@AbominableFirebug.com>
Cc: "Michael S. Tsirkin" <mst@mellanox.co.il>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

On Tue, Oct 31, 2006 at 03:34:47PM -0500, Richard B. Johnson wrote:
> If you write to the PCI bus and then you read the result, the read 
> __might__ be the
> read that flushes any posted writes rather than the read of device 

Config space writes aren't posted, they're delayed.  So, for example,
you can do the config write on the primary bus, then it hits a bridge on
its way to the destination device.  The bridge is entitled (obviously,
it's unlikely to) drop it, and then the config read can pass by the
config write.

I'm beginning to think Michael Tsirkin has the only solution to this
-- architectures need to check that their hardware blocks until the
config write completion has occurred (and if not, simulate that it has
in software).

