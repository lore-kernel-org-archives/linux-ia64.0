From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 14 Jan 2004 09:41:57 +0000
Subject: IA64 test report:2.4.25-pre4/tiger 2004-1-14: 9/9 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F8401720CD2@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3DA82.A6AC75DE"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3DA82.A6AC75DE
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=

Hardware Configuration:
-----------------------
System Name: ACPI-Tiger
System Type: 4 way 900 Itanium2, tiger
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	MPT scsi host driver
	Seagate ST318406LC boot drive
	IDE floppy and CDROM
	Serial console
	USB mouse
	Ethernet Pro 1000

Software Configuration:
-----------------------
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.4 on 1/14(Shanghai
time)
	2.Bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on
1/14(Shanghai time)

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console				tested ok
3. USB 	keyboard			tested ok
4. ATI (run X window system)		tested ok
5. USB mouse					tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)		tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off				tested ok


           CPU0       CPU1       CPU2       CPU3
 32:          0          5          0          0   IO-SAPIC-edge
keyboard
 34:          0         73          1          0   IO-SAPIC-edge  ide0
 39:          0          5          0          0  IO-SAPIC-level  acpi
 45:          0          7          0          0   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level
usb-uhci
 49:          2       1227          0         13  IO-SAPIC-level
usb-uhci
 50:          0          0          0          0  IO-SAPIC-level
ehci_hcd
 51:          0        428          0          3  IO-SAPIC-level  eth0
 53:          2       4341          0         78  IO-SAPIC-level  ioc0
 54:          0         42          0          0  IO-SAPIC-level  ioc1
239:     272985     272069     271707     271570          LSAPIC  timer
254:         58         55         37         18          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

1.alloc 0xffffffff-0x0 from PCI IO for PCI Bus 00:08 failed
bjon knew this issue.

2.PCI: no interrupt route for 00:00:1f pin A
Please refere bugzilla.kernel.org/show_bug.cgi?id=3D1534=20

Log is attached:
 <<2.4.ZIP>>=20

------_=_NextPart_001_01C3DA82.A6AC75DE
Content-Type: application/x-zip-compressed;
	name="2.4.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.4.ZIP
Content-Disposition: attachment;
	filename="2.4.ZIP"

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
AQA3AAAA1y8AAAAA

------_=_NextPart_001_01C3DA82.A6AC75DE--
