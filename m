From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 18 Dec 2003 09:30:05 +0000
Subject: IA64 test report: 2.6.0-test11/tiger 2003-12-18: 9/9 pass
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3C549.85032F66"
Message-Id: <marc-linux-ia64-107174005310297@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3C549.85032F66
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.6 ia64 kernel=20
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
	USB mouse=20
	USB keyboard
	Ethernet Pro 1000

Software Configuration:
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 12/18(Shanghai =
time)
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
12/18 (Shanghai time)
	resolved 2 conflicts manually

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. serial console			tested ok
3. ATI (run X window system)		tested ok
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)		tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 				tested ok

           CPU0       CPU1       CPU2       CPU3
 29:          0          0          0          0          LSAPIC  =
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  =
cpe_hndlr
 31:          0          0          0          0          LSAPIC  =
cmc_hndlr
 34:          1        182          2          0   IO-SAPIC-edge  ide0
 39:          0          5          0          0  IO-SAPIC-level  acpi
 45:          0          6          1          0   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level  =
ehci_hcd
 49:          0       2063         57          0  IO-SAPIC-level  =
uhci_hcd
 50:          0          0          0          0  IO-SAPIC-level  =
uhci_hcd
 51:          0       4214         60          0  IO-SAPIC-level  eth0
 56:          0       4097        118          0  IO-SAPIC-level  ioc0
 57:          0         42          0          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:    2572798    2566770    2567274    2566821          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:         36         95        106         99          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:
1.alloc 0xffff-0x0 from PCI IO for PCI Bus 0000:08 failed
Known issue, bjorn has idea to fix it.

2. pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for =
device 0000:00:1f.1
ACPI: No IRQ known for interrupt pin A of device 0000:00:1f.1
Please refere http://bugzilla.kernel.org/show_bug.cgi?id=3D1534=20

3. hda: packet command error: status=3D0x51 { DriveReady SeekComplete =
Error }
 <<2.6.ZIP>>=20

------_=_NextPart_001_01C3C549.85032F66
Content-Type: application/x-zip-compressed;
	name="2.6.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.ZIP
Content-Disposition: attachment;
	filename="2.6.ZIP"

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
Ni5sb2dQSwUGAAAAAAEAAQA1AAAAzTIAAAAA

------_=_NextPart_001_01C3C549.85032F66--
