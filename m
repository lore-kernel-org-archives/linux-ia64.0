From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 03 Dec 2003 14:25:48 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) testing report (Tiger)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3B9A9.58FA2F54"
Message-Id: <marc-linux-ia64-107046157807044@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985955514249@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985955514249@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3B9A9.58FA2F54
Content-Type: text/plain;
	charset="gb2312"
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 12/3 (Shanghai =
time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
12/3 (Shanghai time)

	Resolved 1 conflict by hand.(Take change from linux-ia64-2.4)

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console			tested ok
3. USB 	keyboard			tested ok
4. ATI (run X window system)		tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)		tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off			tested ok

           CPU0       CPU1       CPU2       CPU3
 32:          0          0          5          0   IO-SAPIC-edge  =
keyboard
 34:          0          0         71          1   IO-SAPIC-edge  ide0
 39:          0          0          4          0  IO-SAPIC-level  acpi
 45:          0          0       1899          0   IO-SAPIC-edge  serial
 48:          0          1         46          0  IO-SAPIC-level  =
usb-uhci
 49:          7         28       1450          2  IO-SAPIC-level  =
usb-uhci
 50:          0          0          0          0  IO-SAPIC-level  =
ehci_hcd
 51:          0          4        847          0  IO-SAPIC-level  eth0
 53:          5         27       4444          0  IO-SAPIC-level  ioc0
 54:          0          0         42          0  IO-SAPIC-level  ioc1
239:     308674     307900     307548     307036          LSAPIC  timer
254:      14455      14127      14779      13957          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

Please refer Dmesg attached.

[Dmesg, /proc/interrupts, lspci -v , .config are attached below]

 <<2.4.ZIP>>=20
Thanks,
Luming

------_=_NextPart_001_01C3B9A9.58FA2F54
Content-Type: application/x-zip-compressed;
	name="2.4.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.4.ZIP
Content-Disposition: attachment;
	filename="2.4.ZIP"

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
SwUGAAAAAAEAAQA2AAAAiiwAAAAA

------_=_NextPart_001_01C3B9A9.58FA2F54--
