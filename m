From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 31 Oct 2006 19:53:02 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <ada8xiwtg81.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org>
	<adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org>
	<20061024.154347.77057163.davem@davemloft.net>
	<aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com>
	<20061031195312.GD5950@mellanox.co.il>
In-Reply-To: <20061031195312.GD5950@mellanox.co.il> (Michael S. Tsirkin's message of "Tue, 31 Oct 2006 21:53:12 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, matthew@wil.cx, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

 > Here's what I don't understand: according to PCI rules, pci config read
 > can bypass pci config write (both are non-posted).
 > So why does doing it help flush the writes as the comment claims?

No, I don't believe a read of a config register can pass a write of
the same register.  (Someone correct me if I'm wrong)

 - R.
