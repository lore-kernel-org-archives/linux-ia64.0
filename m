From: "Brown, Len" <len.brown@intel.com>
Date: Mon, 03 Apr 2006 17:14:04 +0000
Subject: RE: 2.6.16 not booting due to ACPI  revision 20060127
Message-Id: <CFF307C98FEABE47A452B27C06B85BB616BDD9@hdsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44310983.3070000@bull.net>
In-Reply-To: <44310983.3070000@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: xb <xavier.bru@bull.net>, linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org


>We have platforms that do not boot in 2.6.16, but boot OK with 2.6.15=20
>(loop in ACPI code).

Sounds like it wouldn't have booted any of the 2.6.16 pre-release
candidates either...

>After some investigations, I found this is due to pci buses that are=20
>described in the configuration, but not available in limited=20
>configurations.

>These buses have a _STA method, but no _INI method.
>With 2.6.15, the _STA method is run, and as the bus is not=20
>present, the bus and all devices behind it are ignored.

The non-present busses should still be ignored in 2.6.16,
independent of the STA/INI optimization.

>With 2.6.16, as no _INI method is provided for the bus, _STA method is=20
>not run, and then we loop when executing methods for devices=20
>behind the not present bus.

Need to find out what methods are looping on non-existent
devices, and why STA didn't prevent that.  This is probably
independent of the STA/INI optimization in 20060127.

It sounds like either
1. we're not evaluating _STA someplace in the bus enumeration code
   when we should be, and perhaps this was masked in 2.6.15 when
   we blindly evaluated STA everywhere.

   I'll venture that is the issue here -- the STA/INI optimization
   has unmasked a Linux bug.  Note that the patch to
   again blindly execute STA everwhere would simply re-mask the bug,
   rather than fixing it directly.
or

2. _STA on this box is somehow special and has side effects.


Please open a bugzilla here:
http://bugzilla.kernel.org/enter_bug.cgi?product=ACPI

and attach the output from acpidump
acpidump is available in the latest pmtools here:
http://ftp.kernel.org/pub/linux/kernel/people/lenb/acpi/utils/


>Having a look to ACPI specification, I could find nowhere the=20
>restriction that _STA method is called only when an _INI method is=20
>provided for the device:
>
>"6.5.1 _INI (Init)
>...
>If the _STA method indicates that the device is present, OSPM will=20
>evaluate the _INI for the device (if the _INI method exists) and will=20
>examine each of the children of the device for _INI methods.=20
>If the _STA=20
>method indicates that the device is not present, OSPM will not run the=20
>_INI and will not examine the children of the device for _INI=20
>methods. "

That is true, but it is also true that the ACPI spec doesn't say
how how many times STA will be evaluated, if at all.

> traces -----------------------------------------------
>
>
> Device PC11
> 000060e4:  02 . .  Name _HID
> 000060e9:  03 . . .  PNP0A03  PCI Bus  0x030ad041
> 000060ee:  02 . .  Name _UID
> 000060f3:  03 . . .  0x0b
> 000060f5:  02 . .  Name _ADR
> 000060fa:  03 . . .  0x00
> 000060fc:  02 ---- 'PCI bus number setup by the BIOS'  Method _BBN
> 00006102:  03 . . .  0x00
> 00006103:  03 . . .  Return
> 00006104:  04 . . . .  path: \_SB_.CSFF.IO15.B1__
> 00006117:  02 ---- 'Dynamic_Statu'  Method _STA
> 0000611d:  03 . . .  0x00
> 0000611e:  03 . . .  If
> 00006120:  04 . . . .  LEqual
> 00006121:  05 . . . . .  path: \_SB_.CSFF.IO11.HUBD
> 00006134:  05 . . . . .  0x00
> 00006136:  04 . . . .  Return
> 00006137:  05 . . . . .  0x0f
> 00006139:  03 . . .  Return
> 0000613a:  04 . . . .  0x00
> 0000613c:  02 ---- 'Current Resource Setting'  Method _CRS
> 00006142:  03 . . .  0x00
> 00006143:  03 . . .  Return
> 00006144:  04 . . . .  path: \_SB_.HLRS
> 0000614e:  03 . . .  0x01
> 00006150:  03 . . .  0x01
> 00006152:  02
>

Does this trace show the access to the bus that does not exist?
Where is the loop?

thanks,
-Len
