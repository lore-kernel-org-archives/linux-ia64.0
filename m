From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 26 Nov 2003 15:12:04 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) testing report
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3B42F.A66ED58C"
Message-Id: <marc-linux-ia64-106985955514249@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3B42F.A66ED58C
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 11/26 =
(Shanghai time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
11/26 (Shanghai time)
		failed
	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533  to =
solve  kernel unaligned access when pressing power button

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console			didn't test
3. PS/2 keyboard			tested ok
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				Doesn't work (Both CONFIG_USB_UHCI_ALT and =
CONFIG_USB_UHCI failed)
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	didn't test
9. SCI (eg. Press power button)		tested ok
10. Soft Power off				tested ok

           CPU0       CPU1       CPU2       CPU3      =20
 32:        515          2          0          1   IO-SAPIC-edge  =
keyboard
 33:          2          0          0          0   IO-SAPIC-edge  ide1
 34:          4          0          0         33   IO-SAPIC-edge  ide0
 36:         20          0          0          0   IO-SAPIC-edge  PS/2 =
Mouse
 39:          5          0          0          0  IO-SAPIC-level  acpi
 45:         17          0          0          0   IO-SAPIC-edge  serial
 48:         43          0          0          0  IO-SAPIC-level  =
usb-uhci
 49:        193          0          0          4  IO-SAPIC-level  eth0
 51:       3631         10          3        169  IO-SAPIC-level  =
qla1280
239:     181356     180392     180014     161679          LSAPIC  timer
254:      12686      13140      12899      12983          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

Problems:

1. Failed to bk pull  =
http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22  , Error message was

	" Entire  repository is locked by:
		RESYNC directory.
	ERROR-Unable to lock repository for update"

2.PCI: no interrupt route for 00:00:03 pin B.=20
 <<lion.dsl.ZIP>>=20
3. alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

4. hda:end_request: I/O error, dev 03:00 (hda), sector 0
end_request: I/O error, dev 03:00 (hda), sector 1
end_request: I/O error, dev 03:00 (hda), sector 2


 <<dmesg.24.TXT>>  <<2.4.config.TXT>>  <<lspci.24.TXT>>=20
Thanks
Luming


------_=_NextPart_001_01C3B42F.A66ED58C
Content-Type: application/x-zip-compressed;
	name="lion.dsl.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lion.dsl.ZIP
Content-Disposition: attachment;
	filename="lion.dsl.ZIP"

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
ADoAAADOJQAAAAA=

------_=_NextPart_001_01C3B42F.A66ED58C
Content-Type: text/plain;
	name="dmesg.24.TXT"
Content-Transfer-Encoding: base64
Content-Description: dmesg.24.TXT
Content-Disposition: attachment;
	filename="dmesg.24.TXT"


------_=_NextPart_001_01C3B42F.A66ED58C
Content-Type: text/plain;
	name="2.4.config.TXT"
Content-Transfer-Encoding: base64
Content-Description: 2.4.config.TXT
Content-Disposition: attachment;
	filename="2.4.config.TXT"


------_=_NextPart_001_01C3B42F.A66ED58C
Content-Type: text/plain;
	name="lspci.24.TXT"
Content-Transfer-Encoding: base64
Content-Description: lspci.24.TXT
Content-Disposition: attachment;
	filename="lspci.24.TXT"


------_=_NextPart_001_01C3B42F.A66ED58C--
