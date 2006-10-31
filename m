From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Tue, 31 Oct 2006 20:28:00 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061031202800.GA6866@mellanox.co.il>
List-Id: <linux-ia64.vger.kernel.org>
References: <ada8xiwtg81.fsf@cisco.com>
In-Reply-To: <ada8xiwtg81.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeff@garzik.org, matthew@wil.cx, openib-general@openib.org, linux-pci@atrey.karlin.mff.cuni.cz, David Miller <davem@davemloft.net>

Quoting r. Roland Dreier <rdreier@cisco.com>:
> Subject: Re: Ordering between PCI config space writes and MMIO reads?
> 
>  > Here's what I don't understand: according to PCI rules, pci config read
>  > can bypass pci config write (both are non-posted).
>  > So why does doing it help flush the writes as the comment claims?
> 
> No, I don't believe a read of a config register can pass a write of
> the same register.  (Someone correct me if I'm wrong)

It can if PCI-X/PCI-Ex spec is anything to go by.

For example, see table 2-23, transaction ordering rules, in the PCI-express
spec: it is marked as "Y/N: there are no requirements.  The second transaction
may optionally pass the first transaction or be blocked by it."

In typical systems the OS should take care not to start a new
non-posted transaction before the previous one completed.
In particular, all intel and ppc systems I've seen simply block the CPU
unti the split completion arrives.

I find it hard to believe that Altix des not supply a way to check
that completion for config write transaction has arrived.


-- 
MST
