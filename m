From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 20 Nov 2003 00:33:20 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-106928857021781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 19 November 2003 6:08 am, Yu, Luming wrote:

Thanks for doing this work and posting the results.

> 1. USB mouse doesn't work. ( I need to verify config file)

The driver seems to know about the device:

	Product: USB Wheel Mouse
	host/usb-uhci.c: interrupt, status 3, frame# 1415
	input: USB HID v1.00 Mouse [04fc:0003] on usb1:2.0

although it looks unhappy about it.  The "interrupt, status 3" message
seems to be a warning about an interrupt when the driver didn't expect
it.  I wonder whether this can be reproduced on an x86 box?

You could also try the CONFIG_USB_UHCI_ALT driver instead of the
CONFIG_USB_UHCI one you seem to be using, and see whether that
makes a difference.

> 2.PCI: no interrupt route for 00:00:03 pin B

You say this is a known issue for 2.6, but I can't find any details
or discussion about it.  It looks to me like a firmware problem.
The function at 00:00:03.3 (2.6 nicely tells us which function)
claims it's using INTB, but ACPI isn't telling us which GSI that
corresponds to.  Can you ask your BIOS guys about this?

> 3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

I poked at this again.  The reason this fails is because the
VGA console driver starts up very early and allocates ports
0x3c0-0x3df.  It would be nice if we could figure out a way
to allocate those ports later, after the PCI bridge has been
discovered, so we get the ioport resources correct, but I
don't know a reasonable way to do that.

> 4.> 1. After login, the dmesg return below message. 	(Known issue)
> > ifup-post(864): <sc1236(0,1008,0,20000000000d5b20)>

I just added a patch to remove these messages, so this should
be fixed.

>  <<conf.TXT>>  <<dmesg.24.ZIP>>  <<lspci.24.ZIP>> 

The conf.TXT attachment was empty.

Bjorn

