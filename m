From: Matthew Wilcox <willy@debian.org>
Date: Fri, 13 Dec 2002 03:05:33 +0000
Subject: [Linux-ia64] Problem with pci_read_config_word_nodev in 2.4.20
Message-Id: <marc-linux-ia64-105590709805558@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm trying to get the acpiphp driver going on an HP system.
Unfortunately, it crashes the machine on zx1 systems due to uninitialised
sysdata.  I'm using the 2.4.20 patch from Bjorn, plus the 0.4 acpiphp
driver that was submitted for 2.4.21.

Here's the problem:

acpiphp_enable_slot()
|-> enable_device()
    |-> acpiphp_configure_slot()
	|-> pci_read_config_byte_nodev()
	    |-> build_dev()
		|-> pci_read_config_byte(dev)
		    |-> dev->bus->ops->read_byte()

And the zx1 read_byte operation attempts to dereference a struct which
sysdata points to.  But build_dev() doesn't fill in sysdata, and it has
no easy way to get it.

I really don't know the best way to fix this.  Part of me says to fix
the _nodev() API to take a struct pci_bus *.  Part of me says that's too
big for 2.4 and not necessary for 2.5.  So maybe we should stash the sysdata
in the acpiphp_bridge.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

