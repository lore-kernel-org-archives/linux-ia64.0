From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 03 Dec 2003 14:35:25 +0000
Subject: Latest 2.6 IA64 Baseline (Mosberger) testing report (Tiger)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3B9AA.B0CED03C"
Message-Id: <marc-linux-ia64-107046218607600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3B9AA.B0CED03C
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
	USB mouse
	Ethernet Pro 1000

Software Configuration:
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 12/3 (Shanghai =
time)
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
12/3 (Shanghai time)
	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1634 to fix =
compile-time bug.

	Resolved 1 conflict by hand.(Take change from linux-ia64-2.5)

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. serial console			tested ok
3. ATI (run X window system)		tested ok
4. PS/2 mouse				tested ok
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
 34:          1          0         63          0   IO-SAPIC-edge  ide0
 39:          0          0          4          0  IO-SAPIC-level  acpi
 45:          0          1         94          0   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level  =
ehci_hcd
 49:          1         24       1812          0  IO-SAPIC-level  =
uhci_hcd
 50:          0          0         40          0  IO-SAPIC-level  =
uhci_hcd
 51:          0          2        399          0  IO-SAPIC-level  eth0
 56:          7        128       3828          0  IO-SAPIC-level  ioc0
 57:          0          0         42          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:     203826     198715     198222     197807          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:         34         94         87         91          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:
=20
Please refer dmesg attached .

[Dmesg, /proc/interrupts, lspci -v , .config are attached below]
 <<2.6.ZIP>>=20
Thanks,
Luming



------_=_NextPart_001_01C3B9AA.B0CED03C
Content-Type: application/x-zip-compressed;
	name="2.6.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.ZIP
Content-Disposition: attachment;
	filename="2.6.ZIP"

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
AAABAAEANQAAABcyAAAAAA==

------_=_NextPart_001_01C3B9AA.B0CED03C--
