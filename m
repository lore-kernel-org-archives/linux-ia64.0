From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 28 Jan 2010 23:41:58 +0000
Subject: Re: "new" dependencies on ACPI/BIOS
Message-Id: <201001281641.59213.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
In-Reply-To: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't see the connection between the commits you identified and
the fact that we don't find any host bridge memory windows.

The problem I see is that the PNP0A08:00 host bridge has a bunch
of memory resources that are marked as "Consumer," which means the
bridge doesn't forward those regions downstream.  It's normal for
a bridge to have a couple things like that, e.g., 0xcf8, which the
bridge consumes and turns into config space accesses downstream,
but most of these are huge regions that are obviously supposed to
be Producer, not Consumer.

That would certainly explain why the downstream devices don't work,
but it doesn't explain why they worked prior to 2.6.31.  We've been
checking that Producer/Consumer bit since 463eb297401e in 2005.

Are you sure there wasn't a BIOS change at the time things broke?
I guess if you bisected it, there shouldn't be a BIOS change in the
middle, but I just don't see how this could ever have worked with
the _CRS we're getting from the BIOS.

Bjorn

On Thursday 28 January 2010 02:52:48 pm Luck, Tony wrote:
> _CRS AML buffer:
>   88 0d 00 02 0d 00 00 00 00 00 7f 00 00 00 80 00

WORD addr space descriptor: [bus 00-7f]

>   47 01 f8 0c f8 0c 01 08

I/O port descriptor: [io  0x0cf8-0x0cff]

>                           88 0d 00 01 0c 03 00 00 
>   00 00 f7 0c 00 00 f8 0c

WORD addr space descriptor: [io  0x0000-0x0cf7]

>                           88 0d 00 01 0c 03 00 00 
>   00 10 ff 8f 00 00 00 80

WORD addr space descriptor: [io  0x1000-0x8fff]

>                           87 17 00 00 0d 03 00 00 
>   00 00 00 00 0a 00 ff ff 0b 00 00 00 00 00 00 00
>   02 00

DWORD addr space descriptor: [mem 0x000a0000-0x000bffff]

Byte 4 (0x0d) has bit 0 set, which means this device consumes this
range but does not produce it, i.e., the device (the host bridge)
responds to this region but does not forward transactions to any
downstream devices.  This is in Table 6-42 of the ACPI 4.0 spec.

In the two WORD I/O descriptors preceeding this, bit 0 of byte 4
is clear, which means the bridge *does* forward that range downstream.

resource_to_window() ignores consumer-only resources, which explains
why we aren't treating these memory descriptors as host bridge windows.

>         87 17 00 00 0d 03 00 00 00 00 00 00 0c 00 
>   ff ff 0f 00 00 00 00 00 00 00 04 00

DWORD addr space descriptor: [mem 0x000c0000-0x000fffff]

>                                       87 17 00 00 
>   0d 01 00 00 00 00 00 00 c0 fe ff ff c3 fe 00 00
>   00 00 00 00 04 00

DWORD addr space descriptor: [mem 0xfec00000-0xfec3ffff]

>                     87 17 00 00 0d 01 00 00 00 00 
>   00 c0 d1 fe ff c0 d1 fe 00 00 00 00 00 01 00 00

DWORD addr space descriptor: [mem 0xfed1c000-0xfed1c0ff]

>   87 17 00 00 0d 01 00 00 00 00 00 00 d4 fe ff ff
>   df fe 00 00 00 00 00 00 0c 00

DWORD addr space descriptor: [mem 0xfed40000-0xfedfffff]

>                                 87 17 00 00 0d 01 
>   00 00 00 00 00 00 00 50 ff ff ff 9f 00 00 00 00
>   00 00 00 50

DWORD addr space descriptor: [mem 0x50000000-0x9fffffff]

>               8a 2b 00 00 0d 01 ff ff ff 03 00 00 
>   00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
>   00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
>   00 00

QWORD addr space descriptor: [mem 0x010000000000-0x0100ffffffff]

>         8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 
>   00 00 00 00 01 01 00 00 fe ff ff ff 01 01 00 00
>   00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00

QWORD addr space descriptor: [mem 0x010100000000-0x0101ffffffff]

>   8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
>   00 00 02 01 00 00 fe ff ff ff 02 01 00 00 00 00
>   00 00 00 00 00 00 ff ff ff ff 00 00 00 00

QWORD addr space descriptor: [mem 0x010200000000-0x0102ffffffff]

>                                             8a 2b 
>   00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
>   03 01 00 00 fe ff ff ff 03 01 00 00 00 00 00 00
>   00 00 00 00 ff ff ff ff 00 00 00 00 79 00

QWORD addr space descriptor: [mem 0x010300000000-0x0103ffffffff]

> pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
> pci_root PNP0A08:00: host bridge window [io  0x1000-0x8fff]

> pci 0000:00:13.0: reg 10: [mem 0x5832c000-0x5832cfff]
> pci 0000:00:16.0: reg 10: [mem 0x58300000-0x58303fff 64bit]
> pci 0000:00:16.1: reg 10: [mem 0x58304000-0x58307fff 64bit]
> pci 0000:00:16.2: reg 10: [mem 0x58308000-0x5830bfff 64bit]
> pci 0000:00:16.3: reg 10: [mem 0x5830c000-0x5830ffff 64bit]
> pci 0000:00:16.4: reg 10: [mem 0x58310000-0x58313fff 64bit]
> pci 0000:00:16.5: reg 10: [mem 0x58314000-0x58317fff 64bit]
> pci 0000:00:16.6: reg 10: [mem 0x58318000-0x5831bfff 64bit]
> pci 0000:00:16.7: reg 10: [mem 0x5831c000-0x5831ffff 64bit]
> pci 0000:00:1a.0: reg 20: [io  0x40c0-0x40df]
> pci 0000:00:1a.1: reg 20: [io  0x40a0-0x40bf]
> pci 0000:00:1a.2: reg 20: [io  0x4080-0x409f]
> pci 0000:00:1a.7: reg 10: [mem 0x58328000-0x583283ff]
> pci 0000:00:1d.0: reg 20: [io  0x4060-0x407f]
> pci 0000:00:1d.1: reg 20: [io  0x4040-0x405f]
> pci 0000:00:1d.2: reg 20: [io  0x4020-0x403f]
> pci 0000:00:1d.7: reg 10: [mem 0x58324000-0x583243ff]
> pci 0000:00:1f.2: reg 10: [io  0x4138-0x413f]
> pci 0000:00:1f.2: reg 14: [io  0x414c-0x414f]
> pci 0000:00:1f.2: reg 18: [io  0x4130-0x4137]
> pci 0000:00:1f.2: reg 1c: [io  0x4148-0x414b]
> pci 0000:00:1f.2: reg 20: [io  0x4110-0x411f]
> pci 0000:00:1f.2: reg 24: [io  0x4100-0x410f]
> pci 0000:00:1f.3: reg 10: [mem 0x58320000-0x583200ff 64bit]
> pci 0000:00:1f.3: reg 20: [io  0x4000-0x401f]
> pci 0000:00:1f.5: reg 10: [io  0x4128-0x412f]
> pci 0000:00:1f.5: reg 14: [io  0x4144-0x4147]
> pci 0000:00:1f.5: reg 18: [io  0x4120-0x4127]
> pci 0000:00:1f.5: reg 1c: [io  0x4140-0x4143]
> pci 0000:00:1f.5: reg 20: [io  0x40f0-0x40ff]
> pci 0000:00:1f.5: reg 24: [io  0x40e0-0x40ef]
> pci 0000:01:00.0: reg 10: [mem 0x58260000-0x5827ffff]
> pci 0000:01:00.0: reg 14: [mem 0x58240000-0x5825ffff]
> pci 0000:01:00.0: reg 18: [io  0x3020-0x303f]
> pci 0000:01:00.0: reg 1c: [mem 0x58284000-0x58287fff]
> pci 0000:01:00.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
> pci 0000:01:00.1: reg 10: [mem 0x58220000-0x5823ffff]
> pci 0000:01:00.1: reg 14: [mem 0x58200000-0x5821ffff]
> pci 0000:01:00.1: reg 18: [io  0x3000-0x301f]
> pci 0000:01:00.1: reg 1c: [mem 0x58280000-0x58283fff]
> pci 0000:01:00.1: reg 30: [mem 0xfffe0000-0xffffffff pref]
> pci 0000:00:01.0: PCI bridge to [bus 01-01]
> pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
> pci 0000:00:01.0:   bridge window [mem 0x58200000-0x582fffff]
> pci 0000:00:03.0: PCI bridge to [bus 02-02]
> pci 0000:03:00.0: reg 10: [io  0x2000-0x20ff]
> pci 0000:03:00.0: reg 14: [mem 0x58110000-0x58113fff 64bit]
> pci 0000:03:00.0: reg 1c: [mem 0x58100000-0x5810ffff 64bit]
> pci 0000:03:00.0: reg 30: [mem 0xffe00000-0xffffffff pref]
> pci 0000:00:05.0: PCI bridge to [bus 03-03]
> pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
> pci 0000:00:05.0:   bridge window [mem 0x58100000-0x581fffff]
> pci 0000:00:07.0: PCI bridge to [bus 04-04]
> pci 0000:00:1c.0: PCI bridge to [bus 05-05]
> pci 0000:00:1c.1: PCI bridge to [bus 06-06]
> pci 0000:00:1c.2: PCI bridge to [bus 07-07]
> pci 0000:00:1c.3: PCI bridge to [bus 08-08]
> pci 0000:00:1c.4: PCI bridge to [bus 09-09]
> pci 0000:00:1c.5: PCI bridge to [bus 0a-0a]
> pci 0000:0b:04.0: reg 10: [mem 0x50000000-0x57ffffff pref]
> pci 0000:0b:04.0: reg 14: [io  0x1000-0x10ff]
> pci 0000:0b:04.0: reg 18: [mem 0x58000000-0x5800ffff]
> pci 0000:0b:04.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
> pci 0000:0b:04.0: Boot video device
> pci 0000:00:1e.0: PCI bridge to [bus 0b-0b] (subtractive decode)
> pci 0000:00:1e.0:   bridge window [io  0x1000-0x1fff]
> pci 0000:00:1e.0:   bridge window [mem 0x50000000-0x580fffff]

