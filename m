From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 12 Nov 2003 11:22:32 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3A90F.43FC9BF4"
Message-Id: <marc-linux-ia64-106863619315583@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3A90F.43FC9BF4
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 11/11 =
(Shanghai time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
11/11 (Shanhai time)

	Successfully automerged by bk without out any manually work.

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk	tested ok
2. serial console		tested ok
3. PS/2 keyboard		tested ok
4. ATI (run X window system)	tested ok
5. PS/2 mouse			tested ok
6. USB mouse			Doesn't work
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)	tested ok

CPU0       CPU1       CPU2       CPU3
 32:        955          3         18          4   IO-SAPIC-edge  =
keyboard
 33:        758          1         12          2   IO-SAPIC-edge  ide1
 34:         35          3          0          0   IO-SAPIC-edge  ide0
 36:       1155          1         62          5   IO-SAPIC-edge  PS/2 =
Mouse
 39:          5          0          0          0  IO-SAPIC-level  acpi
 44:          8          0          0          0   IO-SAPIC-edge  serial
 45:         17          0          0          0   IO-SAPIC-edge  serial
 48:         50          0          0          0  IO-SAPIC-level  =
usb-uhci
 49:        416          2         16          3  IO-SAPIC-level  eth0
 51:       6711         50        317         33  IO-SAPIC-level  =
qla1280
239:     415744     405691     414447     414241          LSAPIC  timer
254:      16595      17569      17140      16850          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

1. Unalignment issue.( It appeared when testing power button)
kernel unaligned access to 0xe000000004c2f199, ip=3D0xe000000004615fb1

2. USB doesn't work

3.PCI: no interrupt route for 00:00:03 pin B

4.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Bjron said it =
is harmless)

5.> 1. After login, the dmesg return below message. 	(Bjorn said these =
are unimplemented system call, Need a patch to turn off them)
> ...
> ifup-post(864): <sc1236(0,1008,0,20000000000d5b20)>

 <<dmesg.24.ZIP>>  <<lspci.24.TXT>>  <<conf.TXT>>=20

Thanks,
Luming


------_=_NextPart_001_01C3A90F.43FC9BF4
Content-Type: application/x-zip-compressed;
	name="dmesg.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.24.ZIP
Content-Disposition: attachment;
	filename="dmesg.24.ZIP"

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

------_=_NextPart_001_01C3A90F.43FC9BF4
Content-Type: text/plain;
	name="lspci.24.TXT"
Content-Transfer-Encoding: base64
Content-Description: lspci.24.TXT
Content-Disposition: attachment;
	filename="lspci.24.TXT"

UEsDBBQAAAAIAOeZbC+f6XBMSQMAAEgQAAANAAAAbHNwY2lfMjQxLlRYVN2VW0/iQBTH3038DucR
EtHplUqyD4i3Zu2KVjYkhodpO4Vm22kzLbr66fe03IpIubi7ifYBSJk55/zP/zdzCGkR5ZiAabfB
EYE3ZC0wecZC6MQiOQZDVpry5Rl0TbOvFatqgj0BkeqHBzB9LkM6TFvgjFOIaJoxcQQR84JxBB57
Sll4BCHNGHdfgBweHB6QIqUE5vkFBJhK+NStzooLZ1mhloh42Ah8MAg8WkW6QakWe+ykL/gyWgrY
gh7/xeNnnlcUuAxUSXX3EaCri13myS0kschSoBlIhGA9afDKvkn6YCFThp59hkXwTMRhyESVznzl
qs48bu+6Y/5XlUdg3t+BaqxRq/vGTK0il9QqYFtn47RKZLHgHYg+ImlJxpqS3cIgL0ipEzJvsOqV
iqega3aWa9cNhWgKdNELQaMo31v8L8Q4yeB8UtOqZzKmMm9r/XqjjSEHHzsrGhZ2kY2Y4AxlrCVJ
05onxskpPM7XYtU5l4NpgcbGbhdRTuESC1tkvGn/gJiDFecvnJgKbx81c6ROF7stFsXiJTeHTB+f
+iz/hpoiN5wgOwIe80YimM8yd5R3vz41Tv0+WMvm/CTq6qA6W5Fsi2ySVQrUoQl1gjDIAobaHz13
AN34mQmwKKdDFjGewRMTaYBdk2cm6mjiz6s2+hclNAtyjspWth9MeGDuiMdhPMS46IoL9xgN+jcT
++TmmzsBo/2LKwE/kyTgw41OaqSytw7Ztre6tdZKY26lrOkbvPT97fItkXPxO6G8cOr+1noTzy3i
rV4ZsvF9PQ3aNjRIBGm4jvGUvTdyVZ1c9aEBhjr5ZRe2QtvzBEvT0iyBmt3u1KenW9nIwq6BVzDx
83thdsmiEKlFZBRid2wTsYlFjmsZ6rsbZNmdJjftriRLOoHzMcWCRpRzLKwXZoIqkxB4XblYRyym
ivT3FZWjruCNjjUr8dZ1a/S6mW1pDZHGDkRKf5lIaT8iVbWCSGlmpJ9Pv46JVGaNJBwPKwaNqusI
T/4OZ2LGvGJPN99TJsi87s7Z3GPOE0l2quf81Cl5gwdbzpOJm9gL9av2gjW35XHeC+MT90Kp6oXn
7dwL98v2Qtu5F/4n7oVa1Qt3Zy4k+cv2Yicu/gBQSwECFAsUAAAACADnmWwvn+lwTEkDAABIEAAA
DQAAAAAAAAABACAAAAAAAAAAbHNwY2lfMjQxLlRYVFBLBQYAAAAAAQABADsAAAB0AwAAAAA=

------_=_NextPart_001_01C3A90F.43FC9BF4
Content-Type: text/plain;
	name="conf.TXT"
Content-Transfer-Encoding: base64
Content-Description: conf.TXT
Content-Disposition: attachment;
	filename="conf.TXT"


------_=_NextPart_001_01C3A90F.43FC9BF4--
