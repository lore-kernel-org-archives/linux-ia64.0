From: Zwane Mwaikambo <zwane@linuxpower.ca>
Date: Fri, 26 Mar 2004 03:03:56 +0000
Subject: RE: RE[PATCH]2.6.5-rc2 MSI Support for IA64
Message-Id: <Pine.LNX.4.58.0403251420590.19857@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <C7AB9DA4D0B1F344BF2489FA165E50240405818C@orsmsx404.jf.intel.com>
In-Reply-To: <C7AB9DA4D0B1F344BF2489FA165E50240405818C@orsmsx404.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Cc: davidm@napali.hpl.hp.com, jgarzik@pobox.com, "Nakajima, Jun" <jun.nakajima@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, greg@kroah.com

On Thu, 25 Mar 2004, Nguyen, Tom L wrote:

> >>  static int nr_msix_devices = 0;
> >
> >ditto for all those other statics.
>
> For readability and maintaining purpose, we prefer to have these static
> variables defined to their initial states.

Understandable.

> >> +#ifndef CONFIG_IA64
> >>  int assign_irq_vector(int irq)
> >>  {
> >
> >We could define this as a weak function with arch override.
>
> Agree. We are thinking of replacing the semantics of assign_irq_vector()
> in existing arch/i386/kernel/io_apic.c with the semantics of
> assign_irq_vector() in drivers/pci/msi.c. With this way,

There shouldn't be a problem replacing it on i386, the only thing is
perhaps making sure it's marked __init when we're not using
CONFIG_PCI_USE_VECTOR

> >current pci_vector_resources() returns strange values when say, last
> >vector was 0x39 and nr_released was 2, semantically, shouldn't the return
> >value be 187?
>
> Glad you pointed it out. I think the function name pci_vector_resources()
> has a little confusion. The purpose of this function is to return the number
> of vectors currently avaiable in the system for any new allocations, not
> already in use. First argument, last, indicates the last vector already
> assigned and second argument, nr_released, indicates the number of vectors
> released by devices being hot-removed.
>
> Regarding your example, the last assigned vector is 0x39, the
> return should be 187 (vectors left available for new allocation) if
> nr_released was 0 (no device is hot-removed). If the device, which claims
> vector 0x39 was hot-removed, then nr_released was 1; as a result,
> pci_vector_resources() returns 188. The case of nr_released of 2 was
> impossible. If you think of the better name for this function, we are glad
> to rename it. Please let's know what you think.

Thanks for clearing that up, i'm not sure of a self descriptive name. I'll
let you use your good judgement.

Otherwise it looks good, thanks for the grinding this out.

	Zwane
