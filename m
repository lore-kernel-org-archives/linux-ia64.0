From: "Yu, Luming" <luming.yu@intel.com>
Date: Tue, 21 Sep 2004 02:30:43 +0000
Subject: RE: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interfacesupport
Message-Id: <3ACA40606221794F80A5670F0AF15F84059309EF@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409201333.42857.dtor_core@ameritech.net>
In-Reply-To: <200409201333.42857.dtor_core@ameritech.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>, Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

>> > > 
>> > > Hi Anil,
>> > > 
>> > > I obviously failed to deliver my idea :) I meant that I 
>would like add eject
>> > > attribute (along with maybe status, hid and some others) 
>to kobjects in
>> > > /sys/firmware/acpi tree.
>> > > 
>> > 
>> > Dmitry,
>> > 
>> >    See the patch I just posted to acpi-devel and lkml (Subject:
>> > [PATCH/RFC] exposing ACPI objects in sysfs).  It exposes 
>acpi objects as
>> > you describe.   Something simple like:
>> > 
>> >  # cat /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/_EJ0
>> > 
>> > Will call the _EJ0 method on the ACPI device.  You can 
>evaluate eject
>> > dependencies using the _EJD method.
>> > 
>> > 	Alex
>> > 
>> 
>> Alex,
>> 
>> While I think that your patch is very important and should 
>be included (maybe
>> if not as is if somebody has some objections but in some 
>other form) I see it
>> more like developer's tool. I imagined status, HID, eject 
>etc. attributes to
>> be sanitized interface to kernel's data, not necessarily 
>causing re-evaluation.
>> 
>
>Dmitry,
>
>   I imagined the sanitized interfaces would be provided via a 
>userspace
>library, similar to how lspci provides a clean interface to all of the
>PCI data.  An "lsacpi" tool could extract the information into 
>something
>more like you suggest.  If you have objects exposed as human
>readable/writable files, I think you'll quickly end up with a _STA
>driver, _HID driver, _CID driver, _ADR driver, _UID driver, 
>_EJx driver,
>etc, etc, etc...  I don't think we want that kind of bloat in 
>the kernel
>(that's what userspace is for ;^).  Providing a solid, direct interface
>to ACPI methods in the kernel seems like the most flexible, powerful
>interface IMHO.  Thanks,
>
>	Alex
>
>> So it could be like this:
>> 
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/status
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/removable
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/lockable
>> ..
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/eject
>> 
>> And your raw access to the ACPI methods could reside under raw:
>> 
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_STA
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_RNV
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_LCK
>> ..
>> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_EJ0
>

  This sounds like a good idea. To call the raw AML methods from
User space, just need to solve the problem of argument passing.
But, some AML methods are risky to be called directly from user space,
Not only because the side effect of its execution, but also because
it could trigger potential AML method bug or interpreter bug, or even
architectural defect.  All of these headache is due to the AML method
 is NOT intended for being used by userspace program.

Thanks,
Luming



  

