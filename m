From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 27 Sep 2004 05:49:11 +0000
Subject: Re: [ACPI] [PATCH] Updated patches for PCI IRQ resource deallocation
Message-Id: <4157A9D7.4090605@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.53.0409251356110.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251401560.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251416570.2908@musoma.fsmlabs.com>
In-Reply-To: <Pine.LNX.4.53.0409251416570.2908@musoma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, long <tlnguyen@snoqualmie.dp.intel.com>, Andrew Morton <akpm@osdl.org>, Greg Kroah-Hartmann <greg@kroah.com>, Len Brown <len.brown@intel.com>, tony.luck@intel.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Zwane Mwaikambo wrote:
> On Sat, 25 Sep 2004, Zwane Mwaikambo wrote:
> 
>> Kenji Kaneshige wrote:
>> 
>> >     - Changed acpi_pci_irq_disable() to leave 'dev->irq' as it
>> >       is. Clearing 'dev->irq' by some magic constant
>> >       (e.g. PCI_UNDEFINED_IRQ) is TBD.
>> 
>> This may not be safe with CONFIG_PCI_MSI, you may want to verify against 
>> that if you already haven't.
>> 

Thank you for commemts.
You are right. If the linux IRQ number is allocated by MSI code,
clearing 'dev->irq' would cause a problem. So we need to consider
clearing 'dev->irq' carefully.

The latest patch doesn't clear 'dev->irq' so far.

>> > +acpi_unregister_gsi (unsigned int irq)
>> > +{
>> > +}
>> > +EXPORT_SYMBOL(acpi_unregister_gsi);
>> 
>> Why not just make these static inlines in header files? Since you're on 
>> this, how about making irq_desc and friends dynamic too?
> 
> Sorry, i broke Cc.
> 

I'm not quite sure what you are saying, but my idea is defining
acpi_unregister_gsi() as a opposite part of acpi_register_gsi().
Acpi_register_gsi() is defined for each arch (i386, ia64), so
acpi_unregister_gsi() is defined for each i386 and ia64 too. 

Thanks,
Kenji Kaneshige

