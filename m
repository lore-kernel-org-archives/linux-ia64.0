From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 10 Dec 2003 09:41:01 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) testing report (Lion)
Message-Id: <marc-linux-ia64-107104939019896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985955514249@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985955514249@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
============Hardware Configuration:
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 12/10 (Shanghai time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on 12/10 (Shanghai time)
	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id33  to solve  kernel unaligned access when pressing power button

	Auto-merged without any manual work.

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console				tested ok
3. PS/2 keyboard			tested ok
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				Doesn't work (Both CONFIG_USB_UHCI_ALT and CONFIG_USB_UHCI failed)
7. NIC (eg. Ping or ftp)			tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off			tested ok

           CPU0       CPU1       CPU2       CPU3       
 32:        493          8          0          4   IO-SAPIC-edge  keyboard
 33:        415         16          0          1   IO-SAPIC-edge  ide1
 34:         34          2          0          2   IO-SAPIC-edge  ide0
 36:       1226        415         29         51   IO-SAPIC-edge  PS/2 Mouse
 39:          9          0          0          0  IO-SAPIC-level  acpi
 45:         17          0          0          0   IO-SAPIC-edge  serial
 48:         27          0          0          0  IO-SAPIC-level  usb-uhci
 49:       3637        244          3          4  IO-SAPIC-level  eth0
 51:       6356        338         18         52  IO-SAPIC-level  qla1280
239:    3321412    3311351    3320288    3319986          LSAPIC  timer
254:      17988      19901      19438      19488          LSAPIC  IPI
NMI:          0          0          0          0 
ERR:          0

Problems:
1. USB mouse cannot work
USB mose doesn't work like previous report.

2.PCI: no interrupt route for 00:00:03 pin B. (Known issue)


