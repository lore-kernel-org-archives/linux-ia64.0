From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 18 Dec 2003 09:23:37 +0000
Subject: IA64 test report: 2.4.24-pre1/Lion 2003-12-18: 9/8 pass
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3C548.9DFBD2E5"
Message-Id: <marc-linux-ia64-107173948809716@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3C548.9DFBD2E5
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

	ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
	=
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
		1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 12/18 =
(Shanghai time)
		2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
12/18 (Shanghai time)
		resolved 2 conflicts manually

	ACPI Features Tested: (prioritized).
	--------------------
	1. Boot off SCSI disk			tested ok
	2. PS/2 keyboard			tested ok
	3. ATI (run X window system)		tested ok
	4. PS/2 mouse				tested ok
	5. USB mouse				Doesn't work (Both CONFIG_USB_UHCI_ALT and =
CONFIG_USB_UHCI failed)
	6. NIC (eg. Ping or ftp)		tested ok
	7. IDE (eg. r/w floppy or CDROM)	tested ok
	8. SCI (eg. Press power button)		tested ok
	9. Soft Power off			tested ok

           CPU0       CPU1       CPU2       CPU3      =20
 32:        203          1          1          2   IO-SAPIC-edge  =
keyboard
 33:        136          0          0          1   IO-SAPIC-edge  ide1
 34:          6          0          0          2   IO-SAPIC-edge  ide0
 36:        386          0          0          0   IO-SAPIC-edge  PS/2 =
Mouse
 39:          6          0          0          0  IO-SAPIC-level  acpi
 45:         13          0          0          4   IO-SAPIC-edge  serial
 48:         51          0          0          4  IO-SAPIC-level  =
usb-uhci
 49:        800          1          3         41  IO-SAPIC-level  eth0
 51:       3502         11         15        220  IO-SAPIC-level  =
qla1280
239:     339958     339114     338819     327302          LSAPIC  timer
254:         58         55         18         37          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

Problems:
1.Unable to handle kernel NULL pointer dereferencehwclock[44]: Oops =
8804682956800
	Pid: 44, CPU 3, comm:              hwclock

2. USB mouse doesn't work.

3.PCI: no interrupt route for 00:00:03 pin B
Please refere http://bugzilla.kernel.org/show_bug.cgi?id=3D1534=20

4.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed
Known issue, bjorn has idea to fix it.

 <<2.4.config.ZIP>>  <<2.4.ZIP>>=20


------_=_NextPart_001_01C3C548.9DFBD2E5
Content-Type: application/x-zip-compressed;
	name="2.4.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.4.config.ZIP
Content-Disposition: attachment;
	filename="2.4.config.ZIP"

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
BQYAAAAAAQABADwAAADoEgAAAAA=

------_=_NextPart_001_01C3C548.9DFBD2E5
Content-Type: application/x-zip-compressed;
	name="2.4.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.4.ZIP
Content-Disposition: attachment;
	filename="2.4.ZIP"

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
XzQubG9nUEsFBgAAAAABAAEANQAAADMZAAAAAA==

------_=_NextPart_001_01C3C548.9DFBD2E5--
