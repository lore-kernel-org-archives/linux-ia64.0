From: Greg KH <greg@kroah.com>
Date: Thu, 31 Oct 2002 05:58:00 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 30, 2002 at 06:00:40PM -0800, KOCHI, Takayoshi wrote:
> Hi,
> 
> The PCI segment support which was introduced at 2.4.19-020821 ia64 patch
> broke PCI hotplug core driver.  The way ia64 port does is using
> ia64 specific 'pci_controller' structure, embedding a segment
> number in it and making pci_bus->sysdata point to the structure.

Yes, Chris McDermott just sent me a patch much like this one a few days
ago.

> All config space access functions refer to the structure so if
> pci_controller structures are not setup correctly, all pci
> configuration space acesss will fail.
> 
> I don't think the current way of accessing PCI configuration space
> with temporary pci_dev and pci_bus is definitive answer but we
> are depending on it now.
> 
> Could someone enlighten me?
> Any ideas?

The correct thing to do is do what we did in 2.5.  There is no more
*_nodev functions, as we changed the pci_ops structure.  Even when
segment support goes into 2.5, the pci hotplug code should not care at
all.

That being said, I don't think the huge pci_ops change would be a good
thing to do right now in 2.4.  I also do not want to be forced to add
the segment value to the *_nodev functions, as that is just getting too
messy.

Maybe a backport of the pci_ops changes is the best thing to do...

Any other ideas?

thanks,

greg k-h

