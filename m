From: =?iso-8859-1?q?Aur=E9lien_Croc?= <aurelien@ap2c.org>
Date: Sat, 02 Dec 2006 19:58:26 +0000
Subject: AGPGART troubles with Linux 2.6.17-2 -- Itanium 1
Message-Id: <200612022058.28603.aurelien@ap2c.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart19424977.tQPHFDnCo1"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--nextPart19424977.tQPHFDnCo1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,=20

With the Nouveau developers (http://nouveau.freedesktop.org) we tried to us=
e=20
the nouveau driver under a HP i2000 Itanium 1 workstation. Unfortunately, t=
he=20
machine crashed due to some troubles with the agpgart module.

At first, the AGP has a strange version (0.2) and next, nouveau doesn't fin=
d=20
the real maximum bus speed (0x whereas 4x should be found.)

We have forced the use of 1x in the nouveau driver but the kernel crashes..
This does not appears when the AGP is not used by the driver.

Some of the dmesg messages:
agpgart: Found an AGP 0.2 compliant device at 0000:04:14.1.
agpgart: Xorg tried to set rate=3Dx0. Setting to x1 mode.
agpgart: Putting AGP V2 device at 0000:03:00.0 into 1x mode
agpgart: Putting AGP V2 device at 0000:04:14.1 into 1x mode
[drm] allocated 0xe8000000
[drm] DMA command buffer is 1024KiB at 0xe8000000(VRAM)
[drm] FIFO size is 32KiB
[drm] allocated 0x80000000
[drm] allocated 0x81000000
[drm] allocated 0xe8100000
[drm] allocated 0xea100000
[drm] allocated 0xea110000

Regards,=20


=2D-=20
M. Aur=E9lien Croc
Projet AP=B2C - http://www.ap2c.org
Clef Publique : http://www.ap2c.org/aurelien.gpg

--nextPart19424977.tQPHFDnCo1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFcdrkLIExy65AhZ0RAvpGAJ9kjjkeUeVJrhb5PA4Tu91dS5XcKwCePZIA
0m5AupXz9bqQ8ITmO/ULvbY=
=Bik7
-----END PGP SIGNATURE-----

--nextPart19424977.tQPHFDnCo1--
