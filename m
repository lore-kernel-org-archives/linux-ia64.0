From: Matthew Wilcox <willy@debian.org>
Date: Wed, 15 Sep 2004 18:01:23 +0000
Subject: [PATCH] build acpiphp modular and on i386/x86_64 [6/5]
Message-Id: <20040915180123.GG642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040903193027.GO642@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040903193027.GO642@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Greg KH <greg@kroah.com>, pcihpd-discuss@lists.sourceforge.net, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


After the first five patches I sent, in order to build acpiphp on
i386/x86_64 or as a module on ia64, we need these exports and defines
currently.  I have a much better scheme in mind but it's not ready yet.
I promise I'll replace this with something much more portable.

diff -urpNX build-tools/dontdiff hotplug-2.6/arch/ia64/pci/pci.c modular-2.6/arch/ia64/pci/pci.c
--- hotplug-2.6/arch/ia64/pci/pci.c	2004-09-13 09:30:28.000000000 -0600
+++ modular-2.6/arch/ia64/pci/pci.c	2004-09-15 11:54:17.886305856 -0600
@@ -354,6 +354,7 @@ pcibios_fixup_device_resources (struct p
 		pci_claim_resource(dev, i);
 	}
 }
+EXPORT_SYMBOL(pcibios_fixup_device_resources);
 
 /*
  *  Called after each bus is probed, but before its children are examined.
diff -urpNX build-tools/dontdiff hotplug-2.6/include/asm-i386/pci.h modular-2.6/include/asm-i386/pci.h
--- hotplug-2.6/include/asm-i386/pci.h	2004-03-16 08:40:36.000000000 -0700
+++ modular-2.6/include/asm-i386/pci.h	2004-09-15 10:50:02.126390608 -0600
@@ -99,6 +99,9 @@ static inline void pcibios_add_platform_
 {
 }
 
+/* XXX: temporary hack for acpiphp */
+#define pcibios_fixup_device_resources()	do { } while (0)
+
 #endif /* __KERNEL__ */
 
 /* implement the pci_ DMA API in terms of the generic device dma_ one */
diff -urpNX build-tools/dontdiff hotplug-2.6/include/asm-ia64/pci.h modular-2.6/include/asm-ia64/pci.h
--- hotplug-2.6/include/asm-ia64/pci.h	2004-09-02 13:56:21.000000000 -0600
+++ modular-2.6/include/asm-ia64/pci.h	2004-09-15 10:52:39.422526206 -0600
@@ -125,6 +125,9 @@ extern unsigned long pcibios_bus_address
 #define pci_bus_address(busdev, addr, flags) \
 		pcibios_bus_address(PCI_CONTROLLER(busdev), (addr), (flags))
 
+/* XXX: temporary hack for acpiphp */
+extern void pcibios_fixup_device_resources(struct pci_dev *, struct pci_bus *);
+
 /* generic pci stuff */
 #include <asm-generic/pci.h>
 
diff -urpNX build-tools/dontdiff hotplug-2.6/include/asm-x86_64/pci.h modular-2.6/include/asm-x86_64/pci.h
--- hotplug-2.6/include/asm-x86_64/pci.h	2004-09-13 09:31:17.000000000 -0600
+++ modular-2.6/include/asm-x86_64/pci.h	2004-09-15 10:50:16.191929342 -0600
@@ -132,6 +132,9 @@ static inline void pcibios_add_platform_
 {
 }
 
+/* XXX: temporary hack for acpiphp */
+#define pcibios_fixup_device_resources()	do { } while (0)
+
 #endif /* __KERNEL__ */
 
 /* generic pci stuff */

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
