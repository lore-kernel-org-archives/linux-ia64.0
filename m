From: Bill Nottingham <notting@redhat.com>
Date: Wed, 20 Feb 2002 16:07:55 +0000
Subject: [Linux-ia64] Re: CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Hesterberg (jh@sgi.com) said: 
> When I try to change CONFIG_USB_UHCI from a module to static (=m to =y),
> I get:
> 
>     drivers/usb/usbdrv.o: In function `alloc_uhci':
>     drivers/usb/usbdrv.o(.text.init+0x7e2): relocation truncated to fit: PCREL21B uhci_pci_remove

My guess would be that it's calling an __init function from an __exit function.

Bill

