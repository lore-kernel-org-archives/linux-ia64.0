From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Tue, 30 Jul 2002 18:04:58 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905858@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for comments.

On Mon, 29 Jul 2002 22:01:28 -0700
Grant Grundler <grundler@cup.hp.com> wrote:

> "KOCHI, Takayoshi" wrote:
> > This patch fixes the behavior and only allocates vectors
> > for existing pci_dev only.
> 
> Another approach is to defer allocating the vector until
> request_irq() registers the interrupt handler. That way,
> only devices that have drivers get interrupts.

But how to distinguish PCI irqs from others?
It seems that all PCI drivers pass its pci_dev structure
as the 4th argument of request_irq, but others won't
(for example, serial.c).

I thought allocating a new vector in request_irq() is another
level of dynamic allocation.

Once I took another approach and wrote a version that
allocates a new vector when a driver calls pcibios_enable,
but it turned out to be problematic because not all PCI
device drivers call pci_enable() at their startup.

It seems that, for i386, irq lookup is done in pcibios_enable()
(to be exact, pcibios_enable_irq() and other functions in
 arch/i386/kernel/pci-irq.c).  So drivers that doesn't
call pci_enable() are just working luckily (due to proper
setting by BIOS etc.)

> > As usual, interrupt sharing often imply performance
> > degradation and such a configuration should be avoided.
> 
> Another way to reduce/avoid sharing of vector table entries is to have
> multiple Vector Tables. Either one for each CPU or each node of
> a ccNUMA-like machine. I thought SGI's NUMA machines implement
> this already but haven't checked.

Yes, once Alan Mayer at sgi did the work.
But ccNUMA platforms can have various connection topology
and simply dividing vector table into the number of nodes
may not the best choice to do.

I think iosapic.c should be as generic as possible enough to
cover all IO SAPIC-based platforms and tuning for specific
ccNUMA platforms should be considered separately.


Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


