From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 31 Oct 2006 19:58:11 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061031195811.GF26964@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061024214724.GS25210@parisc-linux.org> <adar6wxbcwt.fsf@cisco.com> <20061024223631.GT25210@parisc-linux.org> <20061024.154347.77057163.davem@davemloft.net> <aday7r4a3d7.fsf@cisco.com> <adad588tijq.fsf@cisco.com> <20061031195312.GD5950@mellanox.co.il> <ada8xiwtg81.fsf@cisco.com>
In-Reply-To: <ada8xiwtg81.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: "Michael S. Tsirkin" <mst@mellanox.co.il>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

On Tue, Oct 31, 2006 at 11:53:02AM -0800, Roland Dreier wrote:
>  > Here's what I don't understand: according to PCI rules, pci config read
>  > can bypass pci config write (both are non-posted).
>  > So why does doing it help flush the writes as the comment claims?
> 
> No, I don't believe a read of a config register can pass a write of
> the same register.  (Someone correct me if I'm wrong)

I don't see anything in the PCI spec which forbids it, but I would
expect that hardware designers don't actually do that in practice.
