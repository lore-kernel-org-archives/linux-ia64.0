From: Greg KH <greg@kroah.com>
Date: Fri, 13 Dec 2002 05:12:30 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Problem with pci_read_config_word_nodev in 2.4.20
Message-Id: <marc-linux-ia64-105590709805559@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 13, 2002 at 03:05:33AM +0000, Matthew Wilcox wrote:
> 
> I'm trying to get the acpiphp driver going on an HP system.
> Unfortunately, it crashes the machine on zx1 systems due to uninitialised
> sysdata.  I'm using the 2.4.20 patch from Bjorn, plus the 0.4 acpiphp
> driver that was submitted for 2.4.21.
> 
> Here's the problem:
> 
> acpiphp_enable_slot()
> |-> enable_device()
>     |-> acpiphp_configure_slot()
> 	|-> pci_read_config_byte_nodev()
> 	    |-> build_dev()
> 		|-> pci_read_config_byte(dev)
> 		    |-> dev->bus->ops->read_byte()
> 
> And the zx1 read_byte operation attempts to dereference a struct which
> sysdata points to.  But build_dev() doesn't fill in sysdata, and it has
> no easy way to get it.

Um, didn't we go over all of this a few weeks ago?  :)

In the end, yes, it's a problem.  And yes, I'd like to fix it.  But I
haven't gotten a patch from anyone that fixes this correctly.  The only
one I've seen that is halfway sane just sets sysdata to 0, but that
only works on one machine type :)

> I really don't know the best way to fix this.  Part of me says to fix
> the _nodev() API to take a struct pci_bus *.  Part of me says that's too
> big for 2.4 and not necessary for 2.5.  So maybe we should stash the sysdata
> in the acpiphp_bridge.

Yes, for 2.5 this is not a problem.  The _nodev() functions are big
already, we could merge slot and function together to devfn, and then
add another argument if we want to keep it at 6 paramaters...

Any other ideas are welcome.

thanks,

greg k-h

