From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 03 Dec 2003 12:44:53 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) testing report (Lion)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3B99B.3F7596C4"
Message-Id: <marc-linux-ia64-107045559932482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985955514249@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985955514249@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3B99B.3F7596C4
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=

Hardware Configuration:
-----------------------
System Name: ACPI-LION
System Type: 4 way 800M Itanium, Lion
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	QLogic QLA12160, Seagate ST39205LC boot drive
	IDE floppy and CDROM
	Serial console
	PS/2 keyboard and mouse
	USB mouse
	Ethernet Pro 100

Software Configuration:
-----------------------
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 12/3 (Shanghai =
time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
12/3 (Shanghai time)
	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533  to =
solve  kernel unaligned access when pressing power button

	Resolved 1 conflict by hand.(Take change from linux-ia64-2.4)

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console			tested ok
3. PS/2 keyboard			tested ok
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				Doesn't work (Both CONFIG_USB_UHCI_ALT and =
CONFIG_USB_UHCI failed)
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off				tested ok

           CPU0       CPU1       CPU2       CPU3
 32:        666         24          2          6   IO-SAPIC-edge  =
keyboard
 33:        390          7          3          1   IO-SAPIC-edge  ide1
 34:         22         11          1          4   IO-SAPIC-edge  ide0
 36:        434          0          0          0   IO-SAPIC-edge  PS/2 =
Mouse
 39:          5          0          0          0  IO-SAPIC-level  acpi
 44:        136          3          0          0   IO-SAPIC-edge  serial
 45:         15          2          0          0   IO-SAPIC-edge  serial
 48:         27          0          0          0  IO-SAPIC-level  =
usb-uhci
 49:       1027         24          2          2  IO-SAPIC-level  eth0
 51:       5780        224         23         75  IO-SAPIC-level  =
qla1280
239:     475473     474608     474212     464881          LSAPIC  timer
254:      16742      17274      16081      16602          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:
1. USB cannot work

USB mose doesn't work like previous report.

2.PCI: no interrupt route for 00:00:03 pin B.=20

There is only 1 PRT entry below for bus 0, slot 3, pin D in DSDT.and the =
error message reflect that fact.  This error is for device 00:03.3 =
SMBus.
I don't know how to test that device. Actually 2.6 will call =
acpi_pci_irq_derive try to derive IRQ from a parent bridge's, But 2.4 =
will not do that.
Maybe this is a issue. But it will not help this case.

                Package (0x04)
                {
                    0x0003FFFF,=20
                    0x03,=20
                    0x00,=20
                    0x32
                },=20

3.  alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)
Don't know how to fix

4. I don't have floppy in floppy driver, but below message is quite =
boring.
ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  =
0
ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  =
0
hda: No disk in drive

 <<dmesg.24.ZIP>>  <<lion.2.4.config.ZIP>>  <<lspci.24.ZIP>>=20
Thanks,
Luming

------_=_NextPart_001_01C3B99B.3F7596C4
Content-Type: application/x-zip-compressed;
	name="dmesg.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.24.ZIP
Content-Disposition: attachment;
	filename="dmesg.24.ZIP"

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
AQABADsAAAA6FgAAAAA=

------_=_NextPart_001_01C3B99B.3F7596C4
Content-Type: application/x-zip-compressed;
	name="lion.2.4.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lion.2.4.config.ZIP
Content-Disposition: attachment;
	filename="lion.2.4.config.ZIP"

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

------_=_NextPart_001_01C3B99B.3F7596C4
Content-Type: application/x-zip-compressed;
	name="lspci.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.24.ZIP
Content-Disposition: attachment;
	filename="lspci.24.ZIP"

UEsDBBQAAAAIAFilgy+harS6LQQAAKEoAAANAAAAbHNwY2lfMjQxLlRYVO1Z227iSBB93kj5h3ok
Uph0+4aDtA9ckok1IWHCZAcp4qGx28RaY1ttk5nM12+1uYQAJnZ2VtqO4IFrd9U5dU5XmzYhTaJ/
IuAMWjAWgTfhTXCijIfQiUXyCWxNb2iXbeg7ztDMR9UEfwJCT46P/rgM2SRtwniWwpSlGRenMOVe
MJuCx59SHp5CyDIeuc9Ajo+Oj0iei4LTvYAAcwifufvT4cBlOqglIp7UAx9sAg+9PN1IghjMxukz
fpq+itSE++jvKP4RSSiBy8GghlsJsmXgcOfsFpJYZCmwDCghmDoNfvE/qTV6YaTB/aCNaaNMxGHI
xT5KcuQ2JRn3/qrj/MeETsG5+wqGvUnM8u0lMV1bI6bDoNeepfv45APWPfEu9K8Qb6Jz87J7QcrG
IfdG2woY6N++03kN07J1YurQxwoLNp3KufnvQsySDLpzFNtKaJjKua0NT+otDDl6p8tNRHSRPXIR
ccRfaAzTbJzZZ+fwsBqLcKXNRgtkdnFF8+nncImIXlJdt24gjqAXyy/GMRNeJfwrh5zjtB6fxuJZ
CkAWD5/5XL5CTdfq4yA7hSiO6ongPs/cR1nhk4U4xpfRtsdWi8cyRgXx8/Al4tOejNBhCRsHYZAF
HPk9eO4I+vEPLqDHIjbhUx5l8MRFGmBJtKU0Fkrz1+cWqjJNWBZIW6wL1PrmwDfuPkZxGE8wLpbc
hTuMBsPruShaY2PhYrTfs27xOUmCaPKmPibZXb8xKVs/q7ctkL0SSDOtIoV8v1yGuQMufiYsyut/
d9vbCOTmgbbXtWZ/2SGuWUZcSlDcqxhXxK6tzLDI5yHUwTbm7wa5WNDyPMHTdK1/Q23Q6pwslqC+
ZwlWjPiiui9X7bLbIXTaJBpCH3QGDrogFtJv6678eo1mdBdZnUGfatQi0J0xRPLIoggR3YeZYPo8
BHYRFwHEYsHB2uCwHm7Ln6hKY7c/Lav3+Ottc9JNZ9llnEV/l7NoRWcZxh5n0aU8vtxjOg66K6sn
4Wyyp6sbloVekN/hzpNxL5/Tl3PWDeFc9Vceq7JxEqqNCzbORf21ogKXbN5zjZC28QFo80ZZX61o
20rR1nfS9rzKtN2PQNusTNtXiraxk7ZbWW2qfQTaldWmZpMoeo0wh07Vha6pC11XF7qhLnRTXeiW
utAbqkKn6vZ1qm5fp+r2dapuX6fq9nWqbl+n6vZ1qm5fN97R17ssY6+zdP8N7p3h9oFW9SByDn3f
ZmSSmzyRZpjGzfBsmVD+j8yP5DzM0c4nLmCb+2CXj/YCucR9DKrZSzbqXhVQTWXoZS5oFscK3wOP
A2o9DyS158MNJ30ftpcUGmUoVIu821v7T7t1edy4cZJ8Tt66RyFro6srq36QtVDW92xT/xNZjYOs
hbKa6spqHmQtlNVSV1brIGuhrA11ZW0cZN0p6z9QSwECFAsUAAAACABYpYMvoWq0ui0EAAChKAAA
DQAAAAAAAAABACAAAAAAAAAAbHNwY2lfMjQxLlRYVFBLBQYAAAAAAQABADsAAABYBAAAAAA=

------_=_NextPart_001_01C3B99B.3F7596C4--
