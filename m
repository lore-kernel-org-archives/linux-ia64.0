From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 14 Jan 2004 09:29:03 +0000
Subject: RE:  IA64 test report: 2.6.1-rc1/Lion 2004-1-14: 9/10 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F8401720CCF@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3DA80.D938B4F3"
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720CCE@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720CCE@PDSMSX403.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3DA80.D938B4F3
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Sorry wrong log is attached.  It should be:
 <<2.6.ZIP>>=20

>  -----Original Message-----
> From: 	Yu, Luming =20
> Sent:	Wednesday, January 14, 2004 5:15 PM
> To:	linux-acpi
> Cc:	'linux-ia64@vger.kernel.org'
> Subject:	 IA64 test report: 2.6.1-rc1/Lion 2004-1-14: 9/10 pass
>=20
> ACPI Test Report  for 2.6 ia64 kernel=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=

> Hardware Configuration:
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
> 	1.Bk pull form  lia64.bkbits.net/linux-ia64-2.5 on 1/14=20
> (Shanghai time)
> 		pull nothing
> 	2.bk pull from =20
> linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on 1/14 (Shanghai time)
> 		pull nothing
>=20
> ACPI Features Tested: (prioritized).
> --------------------
> 1. Boot 					tested ok
> 2. PS/2 keyboard			Only work for about 5=20
> minutes. Starting X can make keyboard works for a few seconds.
> 3. ATI (run X window system)		tested ok
> 4. PS/2 mouse				tested ok
> 5. USB mouse				tested ok
> 6. NIC (eg. Ping or ftp)			tested ok
> 7. IDE (eg. r/w floppy or CDROM)	tested ok
> 8. SCI (eg. Press power button)		tested ok
> 9.  Soft Power off 			tested ok
> 10. serial console			tested ok
>=20
>            CPU0       CPU1       CPU2
>  29:          0          0          0          LSAPIC  cmc_poll
>  30:          0          0          0  IO-SAPIC-level  cpe_hndlr
>  31:          0          0          0          LSAPIC  cmc_hndlr
>  32:        573          0         10   IO-SAPIC-edge  i8042
>  33:         52          2          0   IO-SAPIC-edge  ide1
>  34:          6          2          0   IO-SAPIC-edge  ide0
>  36:        242          0         24   IO-SAPIC-edge  i8042
>  39:          4          0          0  IO-SAPIC-level  acpi
>  44:          4          3          0   IO-SAPIC-edge  serial
>  45:         14          3          0   IO-SAPIC-edge  serial
>  54:        267          0         32  IO-SAPIC-level  uhci_hcd
>  55:        618         28          7  IO-SAPIC-level  eth0
>  61:       3142        154         18  IO-SAPIC-level  qla1280
> 232:          0          0          0          LSAPIC  mca_rdzv
> 238:          0          0          0          LSAPIC  perfmon
> 239:     260365     255785     255198          LSAPIC  timer
> 240:          0          0          0          LSAPIC  mca_wkup
> 254:         36         90         92          LSAPIC  IPI
> NMI:          0          0          0
> ERR:          0
>=20
> Problems:
>=20
> 1. ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3
> Please refer to http://bugme.osdl.org/show_bug.cgi?id=3D1534
>=20
> 2.  PS/2 keyboard only work for about 5 minutes. Starting X=20
> can make keyboard works for a few seconds.
>=20
> Ps. log file is attatched.
>=20
>  << File: lion (Compressed) >>=20

------_=_NextPart_001_01C3DA80.D938B4F3
Content-Type: application/x-zip-compressed;
	name="2.6.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.ZIP
Content-Disposition: attachment;
	filename="2.6.ZIP"

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

------_=_NextPart_001_01C3DA80.D938B4F3--
