From: Greg KH <greg@kroah.com>
Date: Wed, 20 Feb 2002 17:26:48 +0000
Subject: Re: [Linux-ia64] CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905151@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 20, 2002 at 11:14:24AM -0600, John Hesterberg wrote:
> OK, I think this is because alloc_uhci() calls uhci_pci_remove(),
> which is defined as __devexit.  This gets dropped when it's not a module.
> 
> Below is a quick patch if anyone is interested.
> I don't know if this is right or not, but it links.

It's not the correct thing to do.

> I'll take this up with the USB maintainer(s).

I already know about it :)

> Seems like if they allow CONFIG_USB_UHCI=y,
> then this should be fixed.

It's been fixed for quite some time now in the 2.4.18-pre series.  Grab
2.4.18-rc2 and let me know if you still have this problem.

thanks,

greg k-h

