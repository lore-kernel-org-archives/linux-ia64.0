From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Mon, 26 Nov 2001 16:17:26 +0000
Subject: [Linux-ia64] null pointer in iosapic_pci_fixup()
Message-Id: <marc-linux-ia64-105590698805543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When a device is found behind a pci/pci bridge and this device has no
IRQ decribed in the ACPI table, Linux prints a warning  message:=20
" PCI: Couldn't map irq for (...)"
unfortunately there is a null "bridge" pointer at that point. This makes the
system hang in release 2.4.9 and have a wrong print of bus , device
and irq in kernel 2.4.13.

A posssible patch could be:

--- linux-2.4.13-ori/arch/ia64/kernel/iosapic.c	Mon Nov 26 17:09:49 2001
+++ linux-2.4.13-new/arch/ia64/kernel/iosapic.c	Mon Nov 26 16:42:40 2001
@@ -615,8 +615,8 @@
 					       pin, vector);
 				else
 					printk(KERN_WARNING
-					       "PCI: Couldn't map irq for (B%d,I%d,P%d)o\n",
-					       bridge->bus->number, PCI_SLOT(bridge->devfn),
+					       "PCI: Couldn't map irq for (B%d,I%d,P%d)\n",
+					       dev->bus->number, PCI_SLOT(dev->devfn),
 					       pin);
 			}
 			if (vector >=3D 0) {

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

