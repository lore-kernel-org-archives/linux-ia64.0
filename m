From: Greg KH <greg@kroah.com>
Date: Tue, 12 Nov 2002 00:53:02 +0000
Subject: [Linux-ia64] Re: 2.5.45 cpqphp driver patch w/ intcphp driver enhancements
Message-Id: <marc-linux-ia64-105590709805396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 11, 2002 at 04:20:16PM -0800, Lee, Jung-Ik wrote:
> Hi Greg,
> 
> Here's PCI hotplug driver patch to cpqphp driver in 2.5.45.

Thanks for the patch.  I'm a bit busy today, but should be able to test
this out later tomorrow if all goes well, sorry in advance for the
delay.

That being said, I have a minor nit:

-config HOTPLUG_PCI_COMPAQ
-       tristate "Compaq PCI Hotplug driver"
-       depends on HOTPLUG_PCI && X86
+config HOTPLUG_PCI_COMPAQ_INTEL
+       tristate "Compaq/Intel PCI Hotplug driver"
+       depends on HOTPLUG_PCI

The device is _still_ a Compaq device, Intel just licensed it from them.
Changing the name to an Intel device does Compaq a disservice, and in
the past, when I accidentally did this, they complained loudly.

So I'd stick to the Compaq name only :)

I'll get back to you with actual technical comments on the patch
hopefully by tomorrow evening.

thanks,

greg k-h

