From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 14 Jan 2004 09:37:49 +0000
Subject: IA64 test report: 2.6.1-rc1/tiger 2004-1-14: 9/9 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F8401720CD1@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3DA82.13149C06"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3DA82.13149C06
Content-Type: text/plain;
	charset="us-ascii"
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
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.5 on 1/14 (Shanghai
time)
		pull nothing
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on
1/14 (Shanghai time)
		pull nothing
=09
ACPI Features Tested: (prioritized).
--------------------
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		tested ok
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 			tested ok

           CPU0       CPU1       CPU2       CPU3
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 34:          1          9        226          0   IO-SAPIC-edge  ide0
 39:          0          0         18          0  IO-SAPIC-level  acpi
 45:          0          0          7          0   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level
ehci_hcd
 49:          2         43       2203          0  IO-SAPIC-level
uhci_hcd
 50:          0          0          0          0  IO-SAPIC-level
uhci_hcd
 51:          1          8        520          0  IO-SAPIC-level  eth0
 56:          5        149       6029          0  IO-SAPIC-level  ioc0
 57:          0          0         42          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          0          0          0          0          LSAPIC
perfmon
239:     228703     225347     223459     224441          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         73         91        131        140          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:
1.alloc 0xffff-0x0 from PCI IO for PCI Bus 0000:08 failed
bjorn knew this issue.

2. pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:1f.1
ACPI: No IRQ known for interrupt pin A of device 0000:00:1f.1

Please refere bugzilla.kernel.org/show_bug.cgi?id=3D1534=20

 <<2.6.ZIP>>=20


------_=_NextPart_001_01C3DA82.13149C06
Content-Type: application/x-zip-compressed;
	name="2.6.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.ZIP
Content-Disposition: attachment;
	filename="2.6.ZIP"

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

------_=_NextPart_001_01C3DA82.13149C06--
