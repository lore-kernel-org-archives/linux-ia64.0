From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 30 Jul 2002 05:01:28 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905852@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" wrote:
> This patch fixes the behavior and only allocates vectors
> for existing pci_dev only.

Another approach is to defer allocating the vector until
request_irq() registers the interrupt handler. That way,
only devices that have drivers get interrupts.

> As usual, interrupt sharing often imply performance
> degradation and such a configuration should be avoided.

Another way to reduce/avoid sharing of vector table entries is to have
multiple Vector Tables. Either one for each CPU or each node of
a ccNUMA-like machine. I thought SGI's NUMA machines implement
this already but haven't checked.

grant

