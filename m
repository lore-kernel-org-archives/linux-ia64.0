From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 10 Dec 2003 10:29:18 +0000
Subject: RE: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107105218122471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> 1. USB mouse doesn't work. ( I need to verify config file)
>
>The driver seems to know about the device:
>
>	Product: USB Wheel Mouse
>	host/usb-uhci.c: interrupt, status 3, frame# 1415
>	input: USB HID v1.00 Mouse [04fc:0003] on usb1:2.0
>
>although it looks unhappy about it.  The "interrupt, status 3" message
>seems to be a warning about an interrupt when the driver didn't expect
>it.  I wonder whether this can be reproduced on an x86 box?
>
>You could also try the CONFIG_USB_UHCI_ALT driver instead of the
>CONFIG_USB_UHCI one you seem to be using, and see whether that
>makes a difference.

USB mouse still doesn't work on lion, but it works on tiger, and this kind of symptom cannot be reproduced on ia32 box.

>> 2.PCI: no interrupt route for 00:00:03 pin B

>You say this is a known issue for 2.6, but I can't find any details
>or discussion about it.  It looks to me like a firmware problem.
>The function at 00:00:03.3 (2.6 nicely tells us which function)
>claims it's using INTB, but ACPI isn't telling us which GSI that
>corresponds to.  Can you ask your BIOS guys about this?

There is only 1 PRT entry in DSDT for bus 0, slot 3,  but it is for pin D  not for pin B . And the error message reflect that fact. 
This error is for device 00:03.3 --SMBus. I don't know how to test that device.
Actually 2.6 will call acpi_pci_irq_derive try to derive IRQ from parent bridge, if nothing found from PRT List, But 2.4 will not do that.
Actually, acpi_pci_irq_enable will not be called in 2.4. Maybe this is a issue. But it will not help this case.

                Package (0x04)
                {
                    0x0003FFFF, 
                    0x03, 
                    0x00, 
                    0x32
                }, 

>> 3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

>I poked at this again.  The reason this fails is because the
>VGA console driver starts up very early and allocates ports
>0x3c0-0x3df.  It would be nice if we could figure out a way
>to allocate those ports later, after the PCI bridge has been
>discovered, so we get the ioport resources correct, but I
>don't know a reasonable way to do that.

Since VGA console driver faile to allocate that port range,  why it still can work?
Does it mean 0x3c0-0x3df is inessential to  VGA console driver.

> 4.> 1. After login, the dmesg return below message. 	(Known issue)
> > ifup-post(864): <sc1236(0,1008,0,20000000000d5b20)>

>I just added a patch to remove these messages, so this should
>be fixed.

It's gone!


