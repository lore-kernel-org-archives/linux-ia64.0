From: John Hesterberg <jh@sgi.com>
Date: Wed, 20 Feb 2002 15:50:38 +0000
Subject: [Linux-ia64] CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I try to change CONFIG_USB_UHCI from a module to static (=m to =y),
I get:

    drivers/usb/usbdrv.o: In function `alloc_uhci':
    drivers/usb/usbdrv.o(.text.init+0x7e2): relocation truncated to fit: PCREL21B uhci_pci_remove

I don't see anything obvious (to me) with the disassembly:

     7e0:   11 60 01 40 00 21       [MIB]       mov r44=r32
     7e6:   00 00 00 02 00 00                   nop.i 0x0
     7ec:   08 00 00 50                         br.call.sptk.many b0~0 <alloc_uhci

It's see the same problem in a different kernel, with the same code
at a different offset (0x672).

Anyone have any idea what's going on with this?

Also, I have some recollection seeing something that said that USB
support has to be a module, maybe because it doesn't see the devices
otherwise?  Any truth to this?

Thanks,

John

