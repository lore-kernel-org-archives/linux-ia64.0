From: Greg KH <greg@kroah.com>
Date: Thu, 24 Oct 2002 21:49:52 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805240@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 24, 2002 at 01:44:06PM -0400, Scott Murray wrote:
> 
> I don't know if you looked at my cPCI driver patch in detail, but it uses
> the setup-*.c code for all of its resource management.

I'm sorry, but I only glanced at it and missed this point.

> The only things that were really missing in 2.4.x were:
> 
> - exports of a few things, most notably pci_scan_bridge
> - code to update the resource windows of a newly added bridge (recursively)
> - a pci_write_bridge_bases
> - PCI resource reservation to allow hot insertion on dumb cPCI hardware
> - on x86, the smarts to work back to the root PCI bus to figure out the
>   IRQ pin to use when looking in the pirq table

All of these seem like things that should belong in the setup-*.c files
for others to use.

> Since I've been swamped with other stuff, I just started finally porting
> my cPCI stuff to 2.5 yesterday. :(  I think I can get it up and running
> relatively quickly, but figuring out Ivan's newer hotplug helper code
> and how to take advantage of it might take me a couple of days.

Nice, I was wondering what happened.  I'll go dig up your older patch
and take a closer look at it.

thanks,

greg k-h

