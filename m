From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 10 Dec 2003 09:46:33 +0000
Subject: RE: Latest 2.4 IA64 Baseline (Bjorn) testing report (Lion)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3BF02.7EACA279"
Message-Id: <marc-linux-ia64-107104967420186@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985955514249@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985955514249@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3BF02.7EACA279
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
		1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 12/10 =
(Shanghai time)
		2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
12/10 (Shanghai time)
		3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533  to =
solve  kernel unaligned access when pressing power button

		Auto-merged without any manual work.

	ACPI Features Tested: (prioritized).
	--------------------
	1. Boot off SCSI disk			tested ok
	2. serial console				tested ok
	3. PS/2 keyboard			tested ok
	4. ATI (run X window system)		tested ok
	5. PS/2 mouse				tested ok
	6. USB mouse				Doesn't work (Both CONFIG_USB_UHCI_ALT and =
CONFIG_USB_UHCI failed)
	7. NIC (eg. Ping or ftp)			tested ok
	8. IDE (eg. r/w floppy or CDROM)	tested ok
	9. SCI (eg. Press power button)		tested ok
	10. Soft Power off			tested ok

	           CPU0       CPU1       CPU2       CPU3      =20
	 32:        493          8          0          4   IO-SAPIC-edge  =
keyboard
	 33:        415         16          0          1   IO-SAPIC-edge  ide1
	 34:         34          2          0          2   IO-SAPIC-edge  ide0
	 36:       1226        415         29         51   IO-SAPIC-edge  PS/2 =
Mouse
	 39:          9          0          0          0  IO-SAPIC-level  acpi
	 45:         17          0          0          0   IO-SAPIC-edge  =
serial
	 48:         27          0          0          0  IO-SAPIC-level  =
usb-uhci
	 49:       3637        244          3          4  IO-SAPIC-level  eth0
	 51:       6356        338         18         52  IO-SAPIC-level  =
qla1280
	239:    3321412    3311351    3320288    3319986          LSAPIC  timer
	254:      17988      19901      19438      19488          LSAPIC  IPI
	NMI:          0          0          0          0=20
	ERR:          0

	Problems:
	1. USB mouse cannot work
	USB mose doesn't work like previous report.

          2.PCI: no interrupt route for 00:00:03 pin B. (Known issue)
=09
	3.  alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known =
issue)
	Don't know how to fix
        =20
=09

------_=_NextPart_001_01C3BF02.7EACA279
Content-Type: application/x-zip-compressed;
	name="lspci.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.24.ZIP
Content-Disposition: attachment;
	filename="lspci.24.ZIP"

UEsDBBQAAAAIAJuNii+harS6LQQAAKEoAAANAAAAbHNwY2lfMjQxLlRYVO1Z227iSBB93kj5h3ok
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
hbKa6spqHmQtlNVSV1brIGuhrA11ZW0cZN0p6z9QSwECFAsUAAAACACbjYovoWq0ui0EAAChKAAA
DQAAAAAAAAABACAAAAAAAAAAbHNwY2lfMjQxLlRYVFBLBQYAAAAAAQABADsAAABYBAAAAAA=

------_=_NextPart_001_01C3BF02.7EACA279
Content-Type: application/x-zip-compressed;
	name="dmesg.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.24.ZIP
Content-Disposition: attachment;
	filename="dmesg.24.ZIP"

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

------_=_NextPart_001_01C3BF02.7EACA279
Content-Type: application/x-zip-compressed;
	name="2.4.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.4.config.ZIP
Content-Disposition: attachment;
	filename="2.4.config.ZIP"

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
BQYAAAAAAQABADwAAADoEgAAAAA=

------_=_NextPart_001_01C3BF02.7EACA279--
