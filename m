From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 19 Nov 2003 12:46:50 +0000
Subject: RE: Latest 2.6 IA64 Baseline (Mosberger) testing report
Message-Id: <marc-linux-ia64-106924607231252@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

It boot with any hang, but  Leagcy  keyboard hang.  --Luming

>  -----Original Message-----
> From: 	Yu, Luming =20
> Sent:	2003=C4=EA11=D4=C219=C8=D5 20:43
> To:	linux-acpi
> Cc:	linux-ia64@vger.kernel.org
> Subject:	Latest 2.6 IA64 Baseline (Mosberger) testing report (Boot hang)
>=20
> ACPI Test Report  for 2.6 ia64 kernel=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> Hardware Configuration:
> -----------------------
> System Name: ACPI-LION
> System Type: 4 way 800M Itanium, Lion
> M/B revision: N/A
> Processor version: N/A
> Firmware Versions: N/A
> I/O configuration summary:
> 	QLogic QLA12160, Seagate ST39205LC boot drive
> 	IDE floppy and CDROM
> 	Serial console
> 	PS/2 keyboard and mouse
> 	USB mouse
> 	Ethernet Pro 100
>=20
> Software Configuration:
> -----------------------
> 	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 11/19 (Shanghai=
 time)
> 	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on 11/=
19 (Shanghai time)
> 	Successfully automerged by bk without out any manually work.
>=20
> 	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=1533 to solve  =
kernel unaligned access when pressing power button
>=20
>=20
> ACPI Features Tested: (prioritized).
> --------------------
> 1. Boot 				tested ok
> 2. serial console			tested ok
> 3. PS/2 keyboard			only work for a few minutes, then hang
> 4. ATI (run X window system)		tested ok
> 5. PS/2 mouse				tested ok
> 6. USB mouse				tested ok
> 7. NIC (eg. Ping or ftp)		tested ok
> 8. IDE (eg. r/w floppy or CDROM)	tested ok
> 9. SCI (eg. Press power button)		tested ok
> 10. Soft Power off				tested ok
>=20
>            CPU0       CPU1       CPU2       CPU3
>  29:          0          0          0          0          LSAPIC  cmc_poll
>  30:          0          0          0          0  IO-SAPIC-level  cpe_hnd=
lr
>  31:          0          0          0          0          LSAPIC  cmc_hnd=
lr
>  32:        724          4         32          0   IO-SAPIC-edge  i8042
>  33:        493          0          9          0   IO-SAPIC-edge  ide1
>  34:         34          0          4          0   IO-SAPIC-edge  ide0
>  36:        777         31         46          0   IO-SAPIC-edge  i8042
>  39:          2          0          0          0  IO-SAPIC-level  acpi
>  44:         16          0          3          0   IO-SAPIC-edge  serial
>  45:         14          0          3          0   IO-SAPIC-edge  serial
>  54:       1656          9         78          2  IO-SAPIC-level  uhci_hcd
>  55:       1032          5         55          1  IO-SAPIC-level  eth0
>  61:       5520         13        279          1  IO-SAPIC-level  qla1280
> 232:          0          0          0          0          LSAPIC  mca_rdzv
> 238:          0          0          0          0          LSAPIC  perfmon
> 239:     354543     349871     349425     348988          LSAPIC  timer
> 240:          0          0          0          0          LSAPIC  mca_wkup
> 254:        154        126        218        183          LSAPIC  IPI
> NMI:          0          0          0          0
> ERR:          0
>=20
> Problems:
>=20
> 1. PS/2 keyboard	only work for a few minutes, then hang.
>=20
> 2.alloc 0x0-0xcf7 from PCI IO for PCI Bus 0000:00 failed. (known issue)
>=20
> 3.ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3. (Known i=
ssue)
>=20
>  << File: dmesg.26.TXT (Compressed) >>  << File: 2.6.config.TXT (Compress=
ed) >>  << File: lspci.26.TXT (Compressed) >>=20
> Thanks,
> Luming
>=20
>=20
