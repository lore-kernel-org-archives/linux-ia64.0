From: Matthew Wilcox <willy@debian.org>
Date: Thu, 18 Mar 2004 16:51:43 +0000
Subject: [PATCH] Fill in bridge resources
Message-Id: <20040318165143.GZ25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


We need to call pci_read_bridge_bases() in pcibios_fixup_bus() otherwise
the bridge resources don't get filled in.  This is a dependency for a
bugfix that will be going in through the pci hotplug people.

Index: arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.7
diff -u -p -r1.7 pci.c
--- a/arch/ia64/pci/pci.c	16 Mar 2004 15:39:51 -0000	1.7
+++ b/arch/ia64/pci/pci.c	18 Mar 2004 16:48:23 -0000
@@ -380,8 +379,7 @@ pcibios_fixup_bus (struct pci_bus *b)
 
 	for (ln = b->devices.next; ln != &b->devices; ln = ln->next)
 		pcibios_fixup_device_resources(pci_dev_b(ln), b);
-
-	return;
+	pci_read_bridge_bases(b);
 }
 
 void __devinit

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
