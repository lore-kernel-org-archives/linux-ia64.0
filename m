From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 22:22:56 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905899@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Fri, 2 Aug 2002 15:44:26 -0600
Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:

> >  pci_irq -> remove (use "acpi_prt" directly?)
> 
> iosapic_init_pci_irq() is the only thing in iosapic.c that uses
> ACPI directly.  I wonder whether that ACPI usage could be
> moved into ia64/kernel/acpi.c, leaving iosapic.c ACPI-free.
> This might make it cleaner for non-ACPI systems, i.e., SGI,
> to use iosapic.

Sounds good.
But iosapic isn't used for sgi systems:)

> There are actually relatively few ia64 dependencies in iosapic.c,
> too, so I could imagine (in the distant future) using it across
> architectures, too.  PA-RISC already uses the same hardware,
> and I wouldn't be surprised if others do eventually.

I didn't know PA-RISC platforms, but obviously i386
has similar configuration and similar hardware (IO-(x)APIC).

> >  iosapic_irq -> iosapic_intr_info
> >  base_irq -> gsi_base
> >  irq -> gsi (where appropriate)
> >  irq -> isa_irq (where appropriate)
> >  irq_type -> as it is
> >       (including no_irq_type, irq_type_iosapic_{level,edge},
> >        irq_type_ia64_lsapic)
> >  iosapic_irq_to_vector() -> gsi_to_vector()
> >        (Note: old gsi_to_vector() is wrongly implemented)
> >
> >  register_irq() -> register_intr()
> >       (including iosapic_register_irq(),
> >                  iosapic_register_platform_irq())
> >  iosacpic_register_legacy_irq() -> iosapic_override_isa_irq()
> >  ia64_alloc_irq() -> ia64_alloc_vector()
> >  ia64_handle_irq() -> ia64_handle_vector() (<-? I'm not sure)
> 
> After doing all the above renaming, there are very few usages
> of "irq" left (only isa_irq and irq_type stuff).  Would it be worth
> reverting to the traditional Linux usage and using "irq" to refer to
> IA64 vectors?

I thought distinguishing "irq" with "IA64 vector" clearly is
important.  Now "irq" and "IA64 vector" is tightly coupled
(one-to-one mapping) but there are other possibilities of
coupling "irq" and "IA64 vector", like Grant says in another
mail or the way SGI took.

> >  max_pin -> max_redir or num_rte
> 
> I like num_rte for the reason you describe.

Thanks;)

> The other things I'd like to see in iosapic.c are:
> 
>   - Standardize on bases used in printk (i.e., hex for GSI, decimal
>     for processor vectors).  Some places print vectors in hex without
>     leading "0x", which is particularly confusing.
>   - Replace printk("... B%d,I%d,P%D...", ...) with
>     printk("... %s INT%c...", dev->slot_name, 'A' + pin).

I'd like, too.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


