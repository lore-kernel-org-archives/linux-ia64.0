From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Tue, 02 Oct 2001 16:24:51 +0000
Subject: [Linux-ia64] pci/pci bus not seen with kernel 2.4.10
Message-Id: <marc-linux-ia64-105590698805292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have problems with pci/pci bridge not seen with kernel 2.4.10 on
ia64 (was OK on 2.4.9). This is due to modifications in ACPI driver:
the acpi_cf_associate_prt_to_bus() routine calls=20
    acpi_os_read_pci_configuration()  with width =3D 1, but the
acpi_os_read_pci_configuration() routine expects width =3D 8 for 1 byte.

I patched and could get the pci/pci buses configured.

--- acpiconf.c-orig    Mon Oct  1 18:39:26 2001
+++ acpiconf.c  Tue Oct  2 18:32:23 2001
@@ -364,7 +364,7 @@
        pci_id.function =3D (u16)(devfn & 0xffff);
=20
        status =3D acpi_os_read_pci_configuration(&pci_id, PCI_PRIMARY_BUS,
-                                               &bn, 1);
+                                             &bn, 8);
        if (ACPI_FAILURE(status)) {
                *retbusnum =3D rpb->rpb_busnum + 1;
                printk("Acpi cfg:%s pci read fail=3D0x%x. b:df:a=3D%x:%x:%x=
\n",
@@ -378,7 +378,7 @@
=20
=20
        status =3D acpi_os_read_pci_configuration(&pci_id, PCI_SECONDARY_BU=
S,
-                                               &bn, 1);
+                                               &bn, 8);
        if (ACPI_FAILURE(status)) {
                *retbusnum =3D rpb->rpb_busnum + 1;
                printk("Acpi cfg:%s pci read fail=3D0x%x. b:df:a=3D%x:%x:%x=
\n",

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-297
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

