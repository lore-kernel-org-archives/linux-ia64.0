From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 18 Dec 2003 09:14:57 +0000
Subject: IA64 test report: 2.6.0-test11/Lion 2003-12-18: 9/9 pass
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3C547.68047DE0"
Message-Id: <marc-linux-ia64-107173908709395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3C547.68047DE0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.6 ia64 kernel=20
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 12/18 =
(Shanghai time)
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
12/18 (Shanghai time)
		resolved 2 conflicts manually

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. PS/2 keyboard			tested ok
3. ATI (run X window system)		tested ok
4. PS/2 mouse				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)		tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9.   Soft Power off 			tested ok

           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC  =
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  =
cpe_hndlr
 31:          0          0          0          0          LSAPIC  =
cmc_hndlr
 32:        886          9          2         21   IO-SAPIC-edge  i8042
 33:        396          2          0          6   IO-SAPIC-edge  ide1
 34:         12         12          0         14   IO-SAPIC-edge  ide0
 36:       2358          0          0         88   IO-SAPIC-edge  i8042
 39:          7          0          0          0  IO-SAPIC-level  acpi
 45:         15          0          0          2   IO-SAPIC-edge  serial
 54:       2910         11          0         51  IO-SAPIC-level  =
uhci_hcd
 55:       1329          3          0         12  IO-SAPIC-level  eth0
 61:       5530         19          1        238  IO-SAPIC-level  =
qla1280
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:     693079     688461     688026     687583          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:        123        155        120        184          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

Problem:

1.alloc 0x0-0xcf7 from PCI IO for PCI Bus 0000:00 failed .
Known issue, bjorn has idea to fix it.

2. pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for =
device 0000:00:03.3
Please refere http://bugzilla.kernel.org/show_bug.cgi?id=3D1534=20


 <<2.6.config.ZIP>>  <<2.6.ZIP>>=20


------_=_NextPart_001_01C3C547.68047DE0
Content-Type: application/x-zip-compressed;
	name="2.6.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.config.ZIP
Content-Disposition: attachment;
	filename="2.6.config.ZIP"

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
UEsFBgAAAAABAAEAPAAAAOsUAAAAAA==

------_=_NextPart_001_01C3C547.68047DE0
Content-Type: application/x-zip-compressed;
	name="2.6.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.ZIP
Content-Disposition: attachment;
	filename="2.6.ZIP"

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
AAAAAQABADUAAABiGwAAAAA=

------_=_NextPart_001_01C3C547.68047DE0--
