From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 03 Dec 2003 13:17:49 +0000
Subject: Latest 2.6 IA64 Baseline (Mosberger) testing report (Lion)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3B99F.D9238F54"
Message-Id: <marc-linux-ia64-107045769502176@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3B99F.D9238F54
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 12/3 (Shanghai =
time)
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
12/3 (Shanghai time)
 	3.patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533 to =
solve  kernel unaligned access when pressing power button=20
	Resolved 1 conflict by hand.(Take change from linux-ia64-2.5)

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. serial console			tested ok
3. PS/2 keyboard			After about 5 minutes, keyboard doesn't respond.
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				tested ok
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off 			tested ok

           CPU0       CPU1       CPU2       CPU3
 29:          0          0          0          0          LSAPIC  =
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  =
cpe_hndlr
 31:          0          0          0          0          LSAPIC  =
cmc_hndlr
 32:       1407          2         10         21   IO-SAPIC-edge  i8042
 33:        638          0          0          2   IO-SAPIC-edge  ide1
 34:         12          0         12         14   IO-SAPIC-edge  ide0
 36:        465         32         21          0   IO-SAPIC-edge  i8042
 39:          4          0          0          0  IO-SAPIC-level  acpi
 44:          6          0          0          2   IO-SAPIC-edge  serial
 45:         15          0          0          2   IO-SAPIC-edge  serial
 54:       2082          4         30          0  IO-SAPIC-level  =
uhci_hcd
 55:       2184          0         28         52  IO-SAPIC-level  eth0
 61:       8850          1         15        279  IO-SAPIC-level  =
qla1280
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:     727038     722365     716577     711104          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:        141        165        273        267          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

1.After login about 5 minutes, keyboard doesn't respond.

2.PCI: no interrupt route for 00:00:03 pin B. (Known issue)

3. alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

4. ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =
=3D  0
ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  =
0
 <<lspci.26.ZIP>>  <<dmesg.26.ZIP>>  <<2.6.config.ZIP>>=20
Thanks,
Luming


------_=_NextPart_001_01C3B99F.D9238F54
Content-Type: application/x-zip-compressed;
	name="lspci.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.26.ZIP
Content-Disposition: attachment;
	filename="lspci.26.ZIP"

UEsDBBQAAAAIABaqgy+Mbl6OLQQAAKEoAAAMAAAAbHNwY2lfMjYuVFhU7VnbTuNIEH1eJP6hHoNE
hm7fibQPucBgDYEMGXYioTw4djtY69hW22GG+fqtdi6EJDY2Oytto+Qh1+6qc+qcrnbahLSI+omA
PWzDhAfelLXAjjIWQjfmySewFNVULjswsO2Rno9qcPYEhJ4cH/1xGTrTtAWTeQozJ80YP4UZ84L5
DDz2lLLwFEInY5H7DOT46PiI5Lko2L0LCDAH9x23PB0OXKWDRsLjaTPwwSLw0M/TjQWI4XySPuOn
2atILbiP/o7iH5GAErgMNKq5tSAbGg63z24hiXmWgpMBJQRTp8Ev9ic1xi+MFLgfdjBtlPE4DBkv
oyRG7lISce+vuvZ/TOgU7LuvoO8QM3xrRUxVNoipMOx35mkZn3zApifehf4V4m10bl52L0idSci8
8a4CGvp3YHdfwzQslegqDLDC3JnNxNz8d87nSQa9BYpdJRRMZd82RifNNoYcv9PlOiK6yB4Zjxji
LzSGrptn1tk5PKzHIlxhs/ESmVVc0Xz6OVwiopdU1+0biCPox+KLSexwrxb+tUN0nNZns5g/CwHI
8uE7PhOv0FCV5iTITiGKo2bCmc8y91FU+GQpjvZlvOux9eIxtHFB/Dx8hfi0LyJ0ncSZBGGQBQz5
PXjuGAbxD8ah70TOlM1YlMET42mAJVFW0hgozV+f26jKLHGyQNhiU6D2Nxu+MfcxisN4inGx5C7c
YTQYXS9EUcythYvRfs+6xeckCaLp2/oY++s3IVXrZ/R3BbLWAim6UaSQ71fLsHDAxc/EifL63932
twK5eaDdda1YX/aIq1cRlxIU9yrGFbFvK9MM8nkETbC0xbthLha0PY+zNN3o39AYtrsnyyWolizB
mhFfVPfFql11O4ROW0RB6MPu0EYXxFz4bdOVX6/RjO4yqz0cUIUaBHpzB5E8OlGEiO7DjDvqIgR2
ERcBxHzJwdjisBlux5+oirnfn4bRf/z1pjkNuu0sq4qz6O9yFq3pLE0rcRZdyeOLPaZro7uyZhLO
pyVdXTMM9IL4DneejHn5nIGYs2kI+2qw9lidjZNQZVKwcS7rrxQVuGLzXmiEtLUPQJuZVX21pm3J
RNs099L2vNq03Y9AW69N25eJtqXtpe3WVpsqH4F2bbWp3iKSXiMsoFN5oSvyQlflha7JC12XF7oh
L3RTVuhU3r5O5e3rVN6+TuXt61Tevk7l7etU3r5O5e3r2jv6es/JnNdZev8G995wZaBlPYhcQC/b
jHRykydSNF27GZ2tEor/kfmRnIc5OvnEJWy9DHb1aC+QK9zHoIq1YiPvVQFVZIZe5YJmeazwPfAY
oNaLQEJ7Ntpy0vdRZ0XBrEKhXuT93io/7VbFcePWSfI5eesehaiNKq+s6kHWQlnfs039T2TVDrIW
yqrLK6t+kLVQVkNeWY2DrIWymvLKah5k3SvrP1BLAQIUCxQAAAAIABaqgy+Mbl6OLQQAAKEoAAAM
AAAAAAAAAAEAIAAAAAAAAABsc3BjaV8yNi5UWFRQSwUGAAAAAAEAAQA6AAAAVwQAAAAA

------_=_NextPart_001_01C3B99F.D9238F54
Content-Type: application/x-zip-compressed;
	name="dmesg.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.26.ZIP
Content-Disposition: attachment;
	filename="dmesg.26.ZIP"

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
AAEAAQA6AAAA5hQAAAAA

------_=_NextPart_001_01C3B99F.D9238F54
Content-Type: application/x-zip-compressed;
	name="2.6.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.config.ZIP
Content-Disposition: attachment;
	filename="2.6.config.ZIP"

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
UEsFBgAAAAABAAEAPAAAAOsUAAAAAA==

------_=_NextPart_001_01C3B99F.D9238F54--
