From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 18 Sep 2002 16:24:04 +0000
Subject: [Linux-ia64] Problem with 2.4.19 and ACPI
Message-Id: <marc-linux-ia64-105590701906039@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,
We found a problem booting 2.4.19 on our IA64 platform.
The new code for ACPI gets the hosts bus address space from ACPI calling
acpi_get_crs_addr().=20
On Bull platform, we have a specific bus that accesses the chipset,
and provides no memory range. This should not be a problem, as
acpi_get_crs_addr() scans the resources of the bus and returns if no
memory range.
Unfortunately, the detection of the end of resources loops on the
ACPI_RSTYPE_END_TAG item due to a wrong size provided in this item,
and sytem does not boot.

Platform boots OK with the following patch:
---------------------------------------------------------------------------=
--
diff --exclude-from /home/xb/proc/diff.exclude -aur 2.4.19.ref/drivers/acpi=
/resources/rsmisc.c 2.4.19/drivers/acpi/resources/rsmiscc.c
--- 2.4.19.ref/drivers/acpi/resources/rsmisc.c	Mon Aug 26 14:01:04 2002
+++ 2.4.19/drivers/acpi/resources/rsmisc.c	Wed Sep 18 16:42:32 2002
@@ -79,7 +79,7 @@
 	/*
 	 * Set the Length parameter
 	 */
-	output_struct->length =3D 0;
+	output_struct->length =3D (u32) struct_size; /*BULL*/
=20
 	/*
 	 * Return the final size of the structure

Traces ------------------------------------------------
0xe00000000440d2a0 acpi_get_crs_next <---- loop
        args (0xe00000001eaffc50, 0xe00000001eaffc40)
        kernel .text 0xe000000004400000 0xe00000000440d2a0 0xe00000000440d3=
20
0xe00000000440d450 acpi_get_crs_addr+0x50
        args (0xe00000001eaffc50, 0x0, 0xe00000001eaffc60, 0xe00000001eaffc=
68, 0xe00000001eaffc70)
        kernel .text 0xe000000004400000 0xe00000000440d400 0xe00000000440d6=
00
0xe00000000440d6b0 acpi_get_addr_space+0xb0
        args (0x0, 0x0, 0xe00000001eaffc60, 0xe00000001eaffc68, 0xe00000001=
eaffc70)
        kernel .text 0xe000000004400000 0xe00000000440d600 0xe00000000440d7=
00
0xe000000004443ef0 pcibios_scan_root+0x90
        args (0xe00000001ea61030, 0xe00000001ea77f00, 0xff, 0xe00000001eaff=
c70, 0xe00000000466cac0)
        kernel .text 0xe000000004400000 0xe000000004443e60 0xe000000004443f=
40
0xe00000000466cac0 acpi_pci_root_add+0x400
        args (0xe00000001eaa5e00, 0xe00000001ea77e8a, 0xe00000001ea77e80, 0=
xe00000001ea77e88, 0xe00000001eaa5e5a)
        kernel .text 0xe000000004400000 0xe00000000466c6c0 0xe00000000466cc=
40
0xe00000000466a0a0 acpi_bus_driver_init+0x160
        args (0xe00000001eaa5e00, 0xe000000004c681e8, 0xe000000004ecfb30, 0=
x309, 0xe00000000466aae0)
        kernel .text 0xe000000004400000 0xe000000004669f40 0xe00000000466a2=
e0
0xe00000000466aae0 acpi_bus_find_driver+0x1a0
        args (0xe00000001eaa5e00, 0xe000000004c681e8, 0xe000000004c680b8, 0=
xffffffffffffffed, 0xe00000000466bf30)
        kernel .text 0xe000000004400000 0xe00000000466a940 0xe00000000466ab=
a0
0xe00000000466bf30 acpi_bus_add+0xc70


0xe00000001eaffc50 00000058 00000000 1ea63100 e0000000   X........1=A6....=
=E0

0xe00000001ea63100 0000000b 00000048 00000002 00000000   ....H...........=20
0xe00000001ea63110 00000000 00000001 00000001 00000000   ................
0xe00000001ea63120 00000000 000000ff 000000ff 00000000   ....=FF...=FF.....=
..
0xe00000001ea63130 00000001 00000000 00000000 00000000   ................
0xe00000001ea63140 00000000 00000000 00000007 00000000
                                              XXXXXXXX length=3D0
0xe00000001ea63150 00000000 00000000 00000000 00000000   ................
0xe00000001ea63160 eaeaeaea eaeaeaea 00000000 00000000   =EA=EA=EA=EA=EA=EA=
=EA=EA........
0xe00000001ea63170 00000000 00000000 00000000 00000000   ................

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________




