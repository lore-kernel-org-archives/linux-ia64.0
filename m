From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 05 Dec 2001 13:51:36 +0000
Subject: [Linux-ia64] USB driver does not build in kernel
Message-Id: <marc-linux-ia64-105590698805618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

I try to build a kernel that integrates the usb-uhci driver and I get
an error at ld time (gcc 2.96 & gcc 3.0.1):

drivers/usb/usbdrv.o: In function `alloc_uhci':
drivers/usb/usbdrv.o(.text.init+0x802): relocation truncated to fit: PCREL2=
1B uhci_pci_remove

I think this is due to uhci_pci_remove() being declared as:

_static void __devexit uhci_pci_remove (struct pci_dev *dev)

and being called by alloc_uhci().

I removed the __devexit attribute and all seems to be OK.
As __devexit should mean "only used at exit time", according to init.h.

A possible patch could be:

--- linux-2.4.16-ori/drivers/usb/usb-uhci.c	Fri Nov  9 22:41:42 2001
+++ linux-2.4.16/drivers/usb/usb-uhci.c	Wed Dec  5 14:49:40 2001
@@ -2845,7 +2845,7 @@
 	s->running =3D 1;
 }
=20
-_static void __devexit
+_static void
 uhci_pci_remove (struct pci_dev *dev)
 {
 	uhci_t *s =3D pci_get_drvdata(dev);

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________



