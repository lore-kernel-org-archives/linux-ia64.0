From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 29 Sep 2004 03:15:05 +0000
Subject: Re: [ACPI] [PATCH] Updated patches for PCI IRQ resource deallocation
Message-Id: <415A28B9.6080504@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.53.0409251356110.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251401560.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251416570.2908@musoma.fsmlabs.com>
 <4157A9D7.4090605@jp.fujitsu.com>
 <Pine.LNX.4.61.0409281702580.3052@musoma.fsmlabs.com>
In-Reply-To: <Pine.LNX.4.61.0409281702580.3052@musoma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, long <tlnguyen@snoqualmie.dp.intel.com>, Andrew Morton <akpm@osdl.org>, Greg Kroah-Hartmann <greg@kroah.com>, Len Brown <len.brown@intel.com>, tony.luck@intel.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hi Zwane,

I'm trying to update my patch based on the feedback from you. Updated
patch defines acpi_unregister_gsi() in both include/asm-i386/acpi.h
and include/asm-ia64/acpi.h. But now I'm having one concern about it.

Some arch specific functions would be called from acpi_unregister_gsi()
when it is implemented. But include/asm-xxx/acpi.h is included before
many other header files, so many 'implicit declaration of function xxx'
warning message would be appeared. These warning messages are disappeared
if we declare all functions called by acpi_unregister_gsi() also in
include/asm-xxx/acpi.h. But I don't like this approach very much.

After all, now I think it is better not to define acpi_unregister_gsi()
in header files.

How do you think?

Thanks,
Kenji Kaneshige

Zwane Mwaikambo wrote:

> On Mon, 27 Sep 2004, Kenji Kaneshige wrote:
> 
>> > > Why not just make these static inlines in header files? Since you're on
>> > > this, how about making irq_desc and friends dynamic too?
>> 
>> I'm not quite sure what you are saying, but my idea is defining
>> acpi_unregister_gsi() as a opposite part of acpi_register_gsi().
>> Acpi_register_gsi() is defined for each arch (i386, ia64), so
>> acpi_unregister_gsi() is defined for each i386 and ia64 too. 
> 
> Well i meant can't you define them in a header file as follows;
> 
> static void inline acpi_unregister_gsi (unsigned int irq)
> {
> }
> 
> An advantage is that it saves memory since you don't also have to create 
> the extra data objects for the exported symbol. But really you don't have 
> to export something which does nothing.
> 
> Thanks,
> 	Zwane
> 

