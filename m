From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Fri, 26 Mar 2004 16:32:44 +0000
Subject: RE: RE[PATCH]2.6.5-rc2 MSI Support for IA64
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502404058199@orsmsx404.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403250121.i2P1LRoO003081@snoqualmie.dp.intel.com>
In-Reply-To: <200403250121.i2P1LRoO003081@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: davidm@napali.hpl.hp.com, jgarzik@pobox.com, "Nakajima, Jun" <jun.nakajima@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, greg@kroah.com, "Nguyen, Tom L" <tom.l.nguyen@intel.com>

On Friday, 26 Mar 2004, Zwane Mwaikambo wrote:

>> >> +#ifndef CONFIG_IA64
>> >>  int assign_irq_vector(int irq)
>> >>  {
>> >
>> >We could define this as a weak function with arch override.
>>
>> Agree. We are thinking of replacing the semantics of assign_irq_vector()
>> in existing arch/i386/kernel/io_apic.c with the semantics of
>> assign_irq_vector() in drivers/pci/msi.c. With this way,
>
>There shouldn't be a problem replacing it on i386, the only thing is
>perhaps making sure it's marked __init when we're not using
>CONFIG_PCI_USE_VECTOR

Good! Will make changes on next update. Regarding __init, thanks for your
suggestion. 

Thanks,
Long
