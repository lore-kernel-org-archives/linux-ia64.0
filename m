From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 02 Aug 2002 21:44:26 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905893@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You've obviously thought about this a lot more than I have,
and I have only these comments:

>  pci_irq -> remove (use "acpi_prt" directly?)

iosapic_init_pci_irq() is the only thing in iosapic.c that uses
ACPI directly.  I wonder whether that ACPI usage could be
moved into ia64/kernel/acpi.c, leaving iosapic.c ACPI-free.
This might make it cleaner for non-ACPI systems, i.e., SGI,
to use iosapic.

There are actually relatively few ia64 dependencies in iosapic.c,
too, so I could imagine (in the distant future) using it across
architectures, too.  PA-RISC already uses the same hardware,
and I wouldn't be surprised if others do eventually.

>  iosapic_irq -> iosapic_intr_info
>  base_irq -> gsi_base
>  irq -> gsi (where appropriate)
>  irq -> isa_irq (where appropriate)
>  irq_type -> as it is
>       (including no_irq_type, irq_type_iosapic_{level,edge},
>        irq_type_ia64_lsapic)
>  iosapic_irq_to_vector() -> gsi_to_vector()
>        (Note: old gsi_to_vector() is wrongly implemented)
>
>  register_irq() -> register_intr()
>       (including iosapic_register_irq(),
>                  iosapic_register_platform_irq())
>  iosacpic_register_legacy_irq() -> iosapic_override_isa_irq()
>  ia64_alloc_irq() -> ia64_alloc_vector()
>  ia64_handle_irq() -> ia64_handle_vector() (<-? I'm not sure)

After doing all the above renaming, there are very few usages
of "irq" left (only isa_irq and irq_type stuff).  Would it be worth
reverting to the traditional Linux usage and using "irq" to refer to
IA64 vectors?

>  register_percpu_irq() -> register_percpu_vector()
>
>  pin -> rte_index
>  pin -> pci_pin (where appropriate)
>  max_pin -> max_redir or num_rte

I like num_rte for the reason you describe.

The other things I'd like to see in iosapic.c are:

  - Standardize on bases used in printk (i.e., hex for GSI, decimal
    for processor vectors).  Some places print vectors in hex without
    leading "0x", which is particularly confusing.
  - Replace printk("... B%d,I%d,P%D...", ...) with
    printk("... %s INT%c...", dev->slot_name, 'A' + pin).

Bjorn


