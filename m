From: John Hesterberg <jh@sgi.com>
Date: Wed, 20 Feb 2002 17:28:59 +0000
Subject: Re: [Linux-ia64] CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905150@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is fixed in 2.4.18-pre2 (or earlier) by removing the __devexit on
uhci_pci_remove.  I wish I'd noticed that sooner. :-)

I'm done replying to my own mails now.

John

On Wed, Feb 20, 2002 at 11:14:24AM -0600, John Hesterberg wrote:
> On Wed, Feb 20, 2002 at 09:50:38AM -0600, John Hesterberg wrote:
> > When I try to change CONFIG_USB_UHCI from a module to static (=m to =y),
> > I get:
> > 
> >     drivers/usb/usbdrv.o: In function `alloc_uhci':
> >     drivers/usb/usbdrv.o(.text.init+0x7e2): relocation truncated to fit: PCREL21B uhci_pci_remove
> 
> OK, I think this is because alloc_uhci() calls uhci_pci_remove(),
> which is defined as __devexit.  This gets dropped when it's not a module.
> 
> Below is a quick patch if anyone is interested.
> I don't know if this is right or not, but it links.
> 
> I'll take this up with the USB maintainer(s).
> Seems like if they allow CONFIG_USB_UHCI=y,
> then this should be fixed.
> 
> John
> 
> diff -Naur 2.4.17-sn2/drivers/usb/usb-uhci.c linux/drivers/usb/usb-uhci.c
> --- 2.4.17-sn2/drivers/usb/usb-uhci.c	Wed Feb 20 17:11:49 2002
> +++ linux/drivers/usb/usb-uhci.c	Wed Feb 20 17:03:53 2002
> @@ -3001,7 +3001,9 @@
>  	s->irq = irq;
>  
>  	if(uhci_start_usb (s) < 0) {
> +#if defined(MODULE) || defined(CONFIG_HOTPLUG)
>  		uhci_pci_remove(dev);
> +#endif
>  		return -1;
>  	}
>  
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

