From: Matthew Wilcox <willy@debian.org>
Date: Thu, 26 Aug 2004 21:51:36 +0000
Subject: [PATCH] Give PCI ROM resources a parent
Message-Id: <20040826215136.GP16196@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Jon Smirl's patch to export roms via sysfs exposes a bug in the ia64
PCI code; we're not assigning a parent to the ROM resource.  Please apply.

Index: vpd-2.6/arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.13
diff -u -p -r1.13 pci.c
--- vpd-2.6/arch/ia64/pci/pci.c	20 Jul 2004 22:05:26 -0000	1.13
+++ vpd-2.6/arch/ia64/pci/pci.c	26 Aug 2004 21:29:48 -0000
@@ -332,7 +332,7 @@ pcibios_fixup_device_resources (struct p
 	struct pci_window *window;
 	int i, j;
 	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
-		PCI_ROM_RESOURCE : PCI_NUM_RESOURCES;
+		PCI_BRIDGE_RESOURCES : PCI_NUM_RESOURCES;
 
 	for (i = 0; i < limit; i++) {
 		if (!dev->resource[i].start)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
