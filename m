From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 10 Dec 2003 09:55:01 +0000
Subject: Latest 2.6 IA64 Baseline (Mosberger) testing report (Lion)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3BF03.ADA7DC9C"
Message-Id: <marc-linux-ia64-107105023920671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3BF03.ADA7DC9C
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 12/10 =
(Shanghai time)
		Nothing to pull
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
12/10 (Shanghai time)
		Nothing to pull
=09
	Since nothing to pull, test result is quite like previous testing =
report.

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. serial console			tested ok
3. PS/2 keyboard			tested ok
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				tested ok
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off 			tested ok

           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC  =
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  =
cpe_hndlr
 31:          0          0          0          0          LSAPIC  =
cmc_hndlr
 32:        888         11          0          0   IO-SAPIC-edge  i8042
 33:        214          6          0          0   IO-SAPIC-edge  ide1
 34:         35          3          0          0   IO-SAPIC-edge  ide0
 36:       2527        100          9         16   IO-SAPIC-edge  i8042
 39:          4          0          0          0  IO-SAPIC-level  acpi
 45:         14          2          0          0   IO-SAPIC-edge  serial
 54:        621         34          0          0  IO-SAPIC-level  =
uhci_hcd
 55:        215          2          1          1  IO-SAPIC-level  eth0
 61:       5059        185          2         16  IO-SAPIC-level  =
qla1280
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:     260134     255454     255013     254565          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:         37        116        119        124          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

Problems:
1.PCI: no interrupt route for 00:00:03 pin B. (Known issue)

2.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

 <<dmesg.26.ZIP>>  <<lspci.26.ZIP>>  <<2.6.config.ZIP>>=20


------_=_NextPart_001_01C3BF03.ADA7DC9C
Content-Type: application/x-zip-compressed;
	name="dmesg.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.26.ZIP
Content-Disposition: attachment;
	filename="dmesg.26.ZIP"

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

------_=_NextPart_001_01C3BF03.ADA7DC9C
Content-Type: application/x-zip-compressed;
	name="lspci.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.26.ZIP
Content-Disposition: attachment;
	filename="lspci.26.ZIP"

UEsDBBQAAAAIAIyOii+Mbl6OLQQAAKEoAAANAAAAbHNwY2lfMjYzLlRYVO1Z207jSBB9XiT+oR6D
RIZu34m0D7nAYA2BDBl2IqE8OHY7WOvYVtthhvn6rXYuhCQ2NjsrbaPkIdfuqnPqnK522oS0iPqJ
gD1sw4QH3pS1wI4yFkI35sknsBTVVC47MLDtkZ6PanD2BISeHB/9cRk607QFk3kKMyfNGD+FGfOC
+Qw89pSy8BRCJ2OR+wzk+Oj4iOS5KNi9CwgwB/cdtzwdDlylg0bC42kz8MEi8NDP040FiOF8kj7j
p9mrSC24j/6O4h+RgBK4DDSqubUgGxoOt89uIYl5loKTASUEU6fBL/YnNcYvjBS4H3YwbZTxOAwZ
L6MkRu5SEnHvr7r2f0zoFOy7r6DvEDN8a0VMVTaIqTDsd+ZpGZ98wKYn3oX+FeJtdG5edi9InUnI
vPGuAhr6d2B3X8M0LJXoKgywwtyZzcTc/HfO50kGvQWKXSUUTGXfNkYnzTaGHL/T5ToiusgeGY8Y
4i80hq6bZ9bZOTysxyJcYbPxEplVXNF8+jlcIqKXVNftG4gj6Mfii0nscK8W/rVDdJzWZ7OYPwsB
yPLhOz4Tr9BQleYkyE4hiqNmwpnPMvdRVPhkKY72ZbzrsfXiMbRxQfw8fIX4tC8idJ3EmQRhkAUM
+T147hgG8Q/Goe9EzpTNWJTBE+NpgCVRVtIYKM1fn9uoyixxskDYYlOg9jcbvjH3MYrDeIpxseQu
3GE0GF0vRFHMrYWL0X7PusXnJAmi6dv6GPvrNyFV62f0dwWy1gIpulGkkO9Xy7BwwMXPxIny+t/d
9rcCuXmg3XWtWF/2iKtXEZcSFPcqxhWxbyvTDPJ5BE2wtMW7YS4WtD2PszTd6N/QGLa7J8slqJYs
wZoRX1T3xapddTuETltEQejD7tBGF8Rc+G3TlV+v0YzuMqs9HFCFGgR6cweRPDpRhIjuw4w76iIE
dhEXAcR8ycHY4rAZbsefqIq535+G0X/89aY5DbrtLKuKs+jvchat6SxNK3EWXcnjiz2ma6O7smYS
zqclXV0zDPSC+A53nox5+ZyBmLNpCPtqsPZYnY2TUGVSsHEu668UFbhi815ohLS1D0CbmVV9taZt
yUTbNPfS9rzatN2PQFuvTduXibal7aXt1labKh+Bdm21qd4ikl4jLKBTeaEr8kJX5YWuyQtdlxe6
IS90U1boVN6+TuXt61Tevk7l7etU3r5O5e3rVN6+TuXt69o7+nrPyZzXWXr/BvfecGWgZT2IXEAv
24x0cpMnUjRduxmdrRKK/5H5kZyHOTr5xCVsvQx29WgvkCvcx6CKtWIj71UBVWSGXuWCZnms8D3w
GKDWi0BCezbactL3UWdFwaxCoV7k/d4qP+1WxXHj1knyOXnrHoWojSqvrOpB1kJZ37NN/U9k1Q6y
FsqqyyurfpC1UFZDXlmNg6yFspryymoeZN0r6z9QSwECFAsUAAAACACMjoovjG5eji0EAAChKAAA
DQAAAAAAAAABACAAAAAAAAAAbHNwY2lfMjYzLlRYVFBLBQYAAAAAAQABADsAAABYBAAAAAA=

------_=_NextPart_001_01C3BF03.ADA7DC9C
Content-Type: application/x-zip-compressed;
	name="2.6.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.config.ZIP
Content-Disposition: attachment;
	filename="2.6.config.ZIP"

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
UEsFBgAAAAABAAEAPAAAAOsUAAAAAA==

------_=_NextPart_001_01C3BF03.ADA7DC9C--
