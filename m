From: Greg KH <greg@kroah.com>
Date: Wed, 05 Dec 2001 18:24:30 +0000
Subject: Re: [Linux-ia64] USB driver does not build in kernel
Message-Id: <marc-linux-ia64-105590698805623@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805618@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805618@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 05, 2001 at 02:51:36PM +0100, Xavier Bru wrote:
> Hello,
> 
> I try to build a kernel that integrates the usb-uhci driver and I get
> an error at ld time (gcc 2.96 & gcc 3.0.1):

A way around this is to enable CONFIG_HOTPLUG, which you probably want
to do anyway if you are using USB.  There is a better patch and
description of why this is happening on linux-kernel right now.

thanks,

greg k-h

