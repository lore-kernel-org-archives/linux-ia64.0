From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 19 Nov 2003 13:08:15 +0000
Subject: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3AE9E.31770FDD"
Message-Id: <marc-linux-ia64-106924777100314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3AE9E.31770FDD
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on 11/19 =
(Shanghai time)
	2.Bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22 on =
11/19 (Shanhai time)
	Successfully automerged by bk without out any manually work.

	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533  to =
solve  kernel unaligned access when pressing power button

ACPI Features Tested: (prioritized).
--------------------
1. Boot off SCSI disk			tested ok
2. serial console			tested ok
3. PS/2 keyboard			tested ok
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				Doesn't work
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off				tested ok

           CPU0       CPU1       CPU2       CPU3
 32:        617          6          1          0   IO-SAPIC-edge  =
keyboard
 33:        317          3          0          1   IO-SAPIC-edge  ide1
 34:         36          0          0          2   IO-SAPIC-edge  ide0
 36:        460          4          0          0   IO-SAPIC-edge  PS/2 =
Mouse
 39:          4          0          0          0  IO-SAPIC-level  acpi
 44:          9          0          0          0   IO-SAPIC-edge  serial
 45:         16          1          0          0   IO-SAPIC-edge  serial
 48:         51          1          0          0  IO-SAPIC-level  =
usb-uhci
 49:        270          7          4          0  IO-SAPIC-level  eth0
 51:       5620        314         33          4  IO-SAPIC-level  =
qla1280
239:     231404     230443     230141     220616          LSAPIC  timer
254:      15752      15328      15507      15285          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

1. USB mouse doesn't work. ( I need to verify config file)

2.PCI: no interrupt route for 00:00:03 pin B

3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)

4.> 1. After login, the dmesg return below message. 	(Known issue)
> ...
> ifup-post(864): <sc1236(0,1008,0,20000000000d5b20)>

 <<conf.TXT>>  <<dmesg.24.ZIP>>  <<lspci.24.ZIP>>=20
Thanks,
Luming

------_=_NextPart_001_01C3AE9E.31770FDD
Content-Type: text/plain;
	name="conf.TXT"
Content-Transfer-Encoding: base64
Content-Description: conf.TXT
Content-Disposition: attachment;
	filename="conf.TXT"


------_=_NextPart_001_01C3AE9E.31770FDD
Content-Type: application/x-zip-compressed;
	name="dmesg.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.24.ZIP
Content-Disposition: attachment;
	filename="dmesg.24.ZIP"

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

------_=_NextPart_001_01C3AE9E.31770FDD
Content-Type: application/x-zip-compressed;
	name="lspci.24.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.24.ZIP
Content-Disposition: attachment;
	filename="lspci.24.ZIP"

UEsDBBQAAAAIAOaocy+NBDjoNQQAAOcrAAANAAAAbHNwY2lfMjQxLlRYVO2ZXW/aShCG7yPlP8wl
kUKz6y8cpF7wkTRWQ0JD0yJFXCz2GqxjbGtt0pP++jM2hkAIxqY9R6cruEiQ452Zd57XO45NSJOo
HwhYgxaMhedMeBOsIOE+dEIRfQBTURvKdRv6ljXUs7Nqgj8DoWenJ5B/rn02iZswnscwY3HCxTnM
uOPNZ+Dw55j75+CzhAf2C5DTk9MTkqWkYHWvwMNUwmV2cVY8cZkVapEIJ3XPBZPAUy9LN1qrZTAf
xy94cLYRsAmPwV9B+CNIK/JsDhrV7EMEGNrrKuviHqJQJDGwBCghWE/s/eQfqTF6lanA46CNRQSJ
CH2fiyKd6ZnbOtO4jzcd6z9VeQ7WwxfQzB1qDddcqlWVNbUqDHrteVwkMjvhHRP9iqQNGTtKtjNA
jhezsc+d0TYrDa+CvtXZrN0wVaKr0EcWgs1m6drs70LMowS6i5q2mSmYyrqvDc/qLQw5+rVrRcfC
rpIpFwFHGTudpOuNC/PiEp5W52LVqS9HeYHm3m5nUS7hGgt7zXjbuoMwgF6YHhiHTDiHqFlZ6vJ1
dY/PQvGSwiH5x2UuT39DTVXqYy85hyAM6pHgLk/sadr9sxyc9nm005urK9HQRsXZsmQlstHeWqAO
i9jY873E46j9ybFH0A9/cAE9FrAJn/EggWcuYg+7piwhGgjx26cW8ptFLPFSH62jbH214Cu3p0Ho
hxOMi1RseMBoMLxd4FMab/YEjPZvbAn4M4q8YLKXpE4KezsmZXtr9HaiNFcoFd3Yw9J1y+XbcM7V
3xELMlIP97038ews3vaWoZifd7tBL+MGStANNyFeZe+NXM0gn4ZQB1NbfBtkWKHlOILH8dosgdqg
1TnLr251rxeqBt6yiZvuC8tNFoXQJlFQyKAzsNA2oUjtum7qL7foZTtPbg36VKEGge6cYUFTFgRY
2KOfCKYuQuB2ZWMdocgVGe8rWo+6ZW8k1ii0t2H0pj/3e5vucKRZwZH0NzuSHuZITStwJF2CdNPp
17HQlUk98ueTgkGjGQaaJz2GMzHhTramn65Zd5B1019584A5T6gyLp7zOSllD4OS82RBE3uhydoL
3ijrx1UvzD+4F2pRLxynci9saXuhV+6F+wf3QivqhV3ZF1SRtheVfUH1JpHizmYhhMoiRJFFiCqL
EE0WIbosQgxZhDTkEEJlmSNUljlCZZkjVJY5QmWZI1SWOUJlmSNUljmiHTBHuixhm8m6v0HFu1FL
SJDjYfFCSNEo1Mldlk/RdO1ueLHMm/5jnT0TdTBVO1uYi9BLiCgfdEtAiZdaVDGX2mS5X6GKPELK
3HjlT2S+ew4HtMMiUGoPPnzjue/D9lJQo4KgagkKXVj87kJde/r75hXAJdn3UiptmCoLefVIvhr5
Q4bk/5K8diRfjbwuC3n9SL4aeUMW8saRfDXyDVnIN47ky5L/B1BLAQIUCxQAAAAIAOaocy+NBDjo
NQQAAOcrAAANAAAAAAAAAAEAIAAAAAAAAABsc3BjaV8yNDEuVFhUUEsFBgAAAAABAAEAOwAAAGAE
AAAAAA==

------_=_NextPart_001_01C3AE9E.31770FDD--
