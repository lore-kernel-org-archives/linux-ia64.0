From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 25 Jul 2001 14:58:53 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Just for the record, I have the same problems, but only on Lions.  Booting
> the SMP kernel on a BigSur works.

Good to hear (I have a Lion here).
I was feeling pretty stupid already because nobody else
seemed to have had problems :-)

It definitely appears that something is wrong with interrupt assignment.
drivers get IRQ 0 and can't do anything with it ...

I have finally got a printout of some boot messages with a serial console.
There are very few differences between a 2.4.5 and 2.4.7 boot, but those
that appear relevant are related to failure in interrupt allocation
(note that the serial driver also says "irq=0").

>>>> 2.4.5:
=====
ttyS00 at 0x03f8 (irq = 44) is a 16550A
ttyS01 at 0x02f8 (irq = 45) is a 16550A
...
keyboard: Timeout - AT keyboard not present?
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: LS-120 SLIM4 00 UHD Floppy, ATAPI FLOPPY drive
hdc: TOSHIBA DVD-ROM SD-C2502, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
ide1 at 0x170-0x177,0x376 on irq 33


>>> 2.4.7:
=====

ACPI: Core Subsystem version [20010615]
ACPI: install SCI 9 handler pass
ACPI: Subsystem enabled
ttyS00 at 0x03f8 (irq = 0) is a 16550A
ttyS01 at 0x02f8 (irq = 0) is a 16550A
...
keyboard: Timeout - AT keyboard not present?
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: IRQ probe failed (0xfffffffffffffdfe)
hda: IRQ probe failed (0xfffffffffffffdfe)
hda: LS-120 SLIM4 00 UHD Floppy, ATAPI FLOPPY drive
hda: IRQ probe failed (0xfffffffffffffdfe)
hdc: IRQ probe failed (0xfffffffffffffdfe)
hdc: IRQ probe failed (0xfffffffffffffdfe)
hdc: TOSHIBA DVD-ROM SD-C2502, ATAPI CD/DVD-ROM drive
hdc: IRQ probe failed (0xfffffffffffffdfe)
hdd: IRQ probe failed (0xfffffffffffffdfe)
hdd: IRQ probe failed (0xfffffffffffffdfe)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
ide1 at 0x170-0x177,0x376 on irq 33

Regards,
Martin

---
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113





