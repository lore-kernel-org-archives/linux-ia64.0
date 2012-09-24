From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 24 Sep 2012 23:54:57 +0000
Subject: Re: [RFC/PATCH v2] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <20120924235457.GA31372@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
 <20120917115619.13d3a3cb@pyramind.ukuu.org.uk>
 <20120920161603.Horde.aF7BBcL8999QWyUjk2AmsNA@webmail.df.eu>
 <CAErSpo6+WYE6wnj4CcKVidNHmg-oGH9SBsvg3QP9syC+vo09HQ@mail.gmail.com>
 <20120924190912.Horde.qznUIqGZi1VQYJO46HeGkwA@webmail.df.eu>
In-Reply-To: <20120924190912.Horde.qznUIqGZi1VQYJO46HeGkwA@webmail.df.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephan Schreiber <info@fs-driver.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

On Mon, Sep 24, 2012 at 07:09:12PM +0200, Stephan Schreiber wrote:
> Mpfff, there aren't many replies; seems I didn't satisfy what you
> want to have...
> 
> At first I want to mention that I just want to help the Debian
> project and started testing Debian Wheezy my old ia64 box.

Thanks, I really appreciate that, and you've done a huge amount of
debugging and testing already.  It's very normal to iterate on the
resolution as we're doing now.

> >The firmware left the memory BAR at 0x24 cleared (0x00000000), but it
> >also left the MEM bit in the command register disabled.  So it seems
> >like a Linux bug that we're trying to use that zero address from the
> >BAR.  If the firmware left the MEM or IO decode enable bit cleared,
> >why would we assume it put anything useful in the corresponding BARs?
> 
> Your idea would be a fundamental change in the Kernel; I just want
> to fix the ata_piix problem in Debian Wheezy.

Right.  I think you've tripped over a rather fundamental issue, and
I'm hoping we can fix that.  If we can, that will help many users,
not just the handful who have this ia64 box.

> If you would evaluate the command registers, which the BIOS or EFI
> has initialized, you would work around some wrong BARs. You might
> run into trouble due to wrong command register values instead.
> Are you sure that any BIOS or EFI sets the command registers correctly?

We can't be 100% sure about things like that, of course.  But we do
know that if the MEM or IO bits are set in the command register, the
device will claim transactions that match whatever is in the BARs.
So setting the MEM or IO bit is a pretty strong statement that the
BAR contains a valid address.  If the BIOS leaves those bits clear,
we really can't conclude anything about the BAR contents.

> Currently the Linux Kernel sets and clears the IORESOURCE_MEM and
> IORESOURCE_IO bits in the command registers as needed.
> Windows reconfigures any PCI device. The settings of the BIOS or EFI
> do not matter at all; the user doesn't experience any BIOS bug at
> all.

On x86, Windows normally doesn't reconfigure PCI devices unless it
finds a problem with the configuration done by the BIOS.  I suspect
it works similarly on ia64.  I would guess that Windows noticed that
the MEM bit was not set, and therefore ignored the MEM BAR contents.

Can you try the following patch?  It's based on 3.6-rc5+, but I think
it will apply to your 3.2.23 kernel with minor conflicts that shouldn't
be too hard to resolve.

It's not quite right because we really shouldn't turn on the MEM or IO
decode bit unless *all* of the corresponding BARs have been set, but
in your case, I think there is only one MEM BAR that is an issue.

Bjorn




commit 9038dd3b3c4c9e4c7ca0118c8df398c4c646ab58
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Mon Sep 24 17:16:28 2012 -0600

    vsprintf: Add support for IORESOURCE_UNSET in %pR

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 0e33754..b6ceeee 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -600,7 +600,7 @@ char *resource_string(char *buf, char *end, struct resource *res,
 	 * 64-bit res (sizeof=8): 20 chars in dec, 18 in hex ("0x" + 16) */
 #define RSRC_BUF_SIZE		((2 * sizeof(resource_size_t)) + 4)
 #define FLAG_BUF_SIZE		(2 * sizeof(res->flags))
-#define DECODED_BUF_SIZE	sizeof("[mem - 64bit pref window disabled]")
+#define DECODED_BUF_SIZE	sizeof("[mem - 64bit pref window unset disabled]")
 #define RAW_BUF_SIZE		sizeof("[mem - flags 0x]")
 	char sym[max(2*RSRC_BUF_SIZE + DECODED_BUF_SIZE,
 		     2*RSRC_BUF_SIZE + FLAG_BUF_SIZE + RAW_BUF_SIZE)];
@@ -642,6 +642,8 @@ char *resource_string(char *buf, char *end, struct resource *res,
 			p = string(p, pend, " pref", str_spec);
 		if (res->flags & IORESOURCE_WINDOW)
 			p = string(p, pend, " window", str_spec);
+		if (res->flags & IORESOURCE_UNSET)
+			p = string(p, pend, " unset", str_spec);
 		if (res->flags & IORESOURCE_DISABLED)
 			p = string(p, pend, " disabled", str_spec);
 	} else {

commit f4795a79dc370b6f4106768b16a4a9edba4df933
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Mon Sep 24 17:15:30 2012 -0600

    PCI: Ignore BAR contents when firmware left decoding disabled

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 2396111..6926dcb 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -175,9 +175,10 @@ int __pci_read_base(struct pci_dev *dev, enum pci_bar_type type,
 
 	mask = type ? PCI_ROM_ADDRESS_MASK : ~0;
 
+	pci_read_config_word(dev, PCI_COMMAND, &orig_cmd);
+
 	/* No printks while decoding is disabled! */
 	if (!dev->mmio_always_on) {
-		pci_read_config_word(dev, PCI_COMMAND, &orig_cmd);
 		pci_write_config_word(dev, PCI_COMMAND,
 			orig_cmd & ~(PCI_COMMAND_MEMORY | PCI_COMMAND_IO));
 	}
@@ -211,9 +212,13 @@ int __pci_read_base(struct pci_dev *dev, enum pci_bar_type type,
 		if (res->flags & IORESOURCE_IO) {
 			l &= PCI_BASE_ADDRESS_IO_MASK;
 			mask = PCI_BASE_ADDRESS_IO_MASK & (u32) IO_SPACE_LIMIT;
+			if (!(orig_cmd & PCI_COMMAND_IO))
+				res->flags |= IORESOURCE_UNSET;
 		} else {
 			l &= PCI_BASE_ADDRESS_MEM_MASK;
 			mask = (u32)PCI_BASE_ADDRESS_MEM_MASK;
+			if (!(orig_cmd & PCI_COMMAND_MEM))
+				res->flags |= IORESOURCE_UNSET;
 		}
 	} else {
 		res->flags |= (l & IORESOURCE_ROM_ENABLE);
@@ -248,6 +253,7 @@ int __pci_read_base(struct pci_dev *dev, enum pci_bar_type type,
 			/* Address above 32-bit boundary; disable the BAR */
 			pci_write_config_dword(dev, pos, 0);
 			pci_write_config_dword(dev, pos + 4, 0);
+			res->flags |= IORESOURCE_UNSET;
 			region.start = 0;
 			region.end = sz64;
 			pcibios_bus_to_resource(dev, res, &region);

commit f90b82ab54efa462681d5dd99fd926f2563f7a93
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Mon Sep 24 17:28:21 2012 -0600

    PCI: Don't claim BARs that haven't been assigned

diff --git a/drivers/pci/setup-res.c b/drivers/pci/setup-res.c
index 81b88bd..9f9e31a 100644
--- a/drivers/pci/setup-res.c
+++ b/drivers/pci/setup-res.c
@@ -113,6 +113,9 @@ int pci_claim_resource(struct pci_dev *dev, int resource)
 	struct resource *res = &dev->resource[resource];
 	struct resource *root, *conflict;
 
+	if (res->flags & IORESOURCE_UNSET)
+		return 0;
+
 	root = pci_find_parent_resource(dev, res);
 	if (!root) {
 		dev_info(&dev->dev, "no compatible bridge window for %pR\n",
@@ -334,6 +337,8 @@ int pci_enable_resources(struct pci_dev *dev, int mask)
 
 		if (!(r->flags & (IORESOURCE_IO | IORESOURCE_MEM)))
 			continue;
+		if (r->flags & IORESOURCE_UNSET)
+			continue;
 		if ((i = PCI_ROM_RESOURCE) &&
 				(!(r->flags & IORESOURCE_ROM_ENABLE)))
 			continue;
