From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Jan 2010 19:22:04 +0000
Subject: "new" dependencies on ACPI/BIOS
Message-Id: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Bjorn: I stuck your name in the "To" list as Jesse told me that you
 know all about this code]

My shiniest, newest, ia64 development system used to work fine. But
in 2.6.31 the USB keyboard and mouse on the console stopped working.
Console log sprouted a new error message:

ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.7: device not available because of BAR 0 [0x58328000-0x583283ff] collisions
ehci_hcd 0000:00:1d.7: device not available because of BAR 0 [0x58324000-0x583243ff] collisions

which explains why USB is broken.  Somebody bisected the .30 to .31 transition
and found this commit as the culprit:

--------------------------------------------------------------------------
commit 1d89b30cc9be41af87881682ec82e2c107849dbe
Author: Matthew Wilcox <willy@linux.intel.com>
Date:   Wed Jun 17 16:33:36 2009 -0400

    ia64: Fix resource assignment for root busses
    
    ia64 was assigning resources to root busses after allocations had
    been made for child busses.  Calling pcibios_setup_root_windows() from
    pcibios_fixup_bus() solves this problem by assigning the resources to
    the root bus before child busses are scanned.
--------------------------------------------------------------------------
    
and indeed reverting that patch from the latest kernels does get
rid of the ehci messages, and the USB keyboard/mouse work again.

BUT ... with the patch reverted I lose some other devices:

ata_piix 0000:00:1f.2: version 2.13
ata_piix 0000:00:1f.2: device not available because of BAR 0 [0x4138-0x413f] collisions
ata_piix: probe of 0000:00:1f.2 failed with error -22
ata_piix 0000:00:1f.5: device not available because of BAR 0 [0x4128-0x412f] collisions
ata_piix: probe of 0000:00:1f.5 failed with error -22

and also:

uhci_hcd 0000:00:1a.1: device not available because of BAR 4 [0x40a0-0x40bf] collisions
uhci_hcd 0000:00:1a.2: device not available because of BAR 4 [0x4080-0x409f] collisions
uhci_hcd 0000:00:1d.0: device not available because of BAR 4 [0x4060-0x407f] collisions
uhci_hcd 0000:00:1d.1: device not available because of BAR 4 [0x4040-0x405f] collisions
uhci_hcd 0000:00:1d.2: device not available because of BAR 4 [0x4020-0x403f] collisions

some more bisection showed that this followup commit is responsible
for not allowing the reversion of willy's commit to fix things:

--------------------------------------------------------------------------
commit 79896cf42f6a96d7e14f2dc3473443d68d74031d
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Aug 2 14:04:19 2009 -0700

    Make pci_claim_resource() use request_resource() rather than insert_resource()
    
    This function has traditionally used "insert_resource()", because before
    commit cebd78a8c5 ("Fix pci_claim_resource") it used to just insert the
    resource into whatever root resource tree that was indicated by
    "pcibios_select_root()".
    
    So there Matthew fixed it to actually look up the proper parent
    resource, which means that now it's actively wrong to then traverse the
    resource tree any more: we already know exactly where the new resource
    should go.
    
    And when we then did commit a76117dfd6 ("x86: Use pci_claim_resource"),
    which changed the x86 PCI code from the open-coded
    
    	pr = pci_find_parent_resource(dev, r);
    	if (!pr || request_resource(pr, r) < 0) {
    
    to using
    
    	if (pci_claim_resource(dev, idx) < 0) {
    
    that "insert_resource()" now suddenly became a problem, and causes a
    regression covered by
    
    	http://bugzilla.kernel.org/show_bug.cgi?id891
    
    which this fixes.
--------------------------------------------------------------------------


The code now appears to walk ACPI looking for _CRS methods to find out
which resources are attached to which busses.  When drivers are paired
up with devices later, we check to make sure that the device has a
correct parent.  For my system this seems to fail because the _CRS walk
only turns up some IO resources and no MEM resources. So the echi
(which wants mem 0x58328000 and mem 0x58324000) is out of luck and
denied.

Here's some output showing what _CRS found:
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci_acpi_scan_root: allocated controller e000000303340b00  <<<< my debug printk
Count of _CRS items for this controller = 2  <<<< my debug printk
pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A08:00: host bridge window [io  0x1000-0x8fff]
Walked _CRS and assigned 2 windows for 'PCI Bus 0000:00'  <<<< my debug printk

and

ACPI: PCI Root Bridge [PCI1] (0000:80)
pci_acpi_scan_root: allocated controller e000000303343380 <<<< my debug printk
Count of _CRS items for this controller = 1 <<<< my debug printk
pci_root PNP0A08:01: host bridge window [io  0x9000-0xfffe]
Walked _CRS and assigned 1 windows for 'PCI Bus 0000:80' <<<< my debug printk

Is this a correct understanding of what the Linux pci code now expects
to find?  Which bit of the ACPI spec should I use to beat the BIOS
engineers over the head to point out the error of their ways?

Are there some options for a quirk, or some other workaround to get my
system up and running on latest kernels (since I'm sure that getting
a fix to the BIOS will be a long, slow process)?

-Tony
