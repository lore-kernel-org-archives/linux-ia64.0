From: "Croxon, Nigel" <nigel.croxon@hp.com>
Date: Wed, 03 Nov 2004 22:05:56 +0000
Subject: [PATCH] Fix for bits_wanted in sba_iommu.c
Message-Id: <1099519556.3351.4.camel@lawrence.croxon.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-zDHTSwAnqxJBI6Z07mgl"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-zDHTSwAnqxJBI6Z07mgl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

bits_wanted is expanded to bytes using the wrong shift value
(when iovp_shift !=3D PAGE_SHIFT), resulting in an explosion of
used iommu resources.

This potentially results in mistakenly running out of DMA mapping
resources when the system is under *heavy* i/o load.

This patch is against 2.6.9 (kernel.org)

Signed-off-by: Nigel Croxon <nigel.croxon@hp.com>
Signed-off by: Alex Williamson <alex.williamson@hp.com>



--- linux/arch/ia64/hp/common/sba_iommu.c.      2004-11-03 14:41:08.0000000=
00 -0500
+++ linux/arch/ia64/hp/common/sba_iommu.c       2004-11-03 14:49:37.0000000=
00 -0500
@@ -478,7 +478,7 @@
         * purges IOTLB entries in power-of-two sizes, so we also
         * allocate IOVA space in power-of-two sizes.
         */
-       bits_wanted =3D 1UL << get_iovp_order(bits_wanted << PAGE_SHIFT);
+       bits_wanted =3D 1UL << get_iovp_order(bits_wanted << iovp_shift);

        if (likely(bits_wanted =3D=3D 1)) {
                unsigned int bitshiftcnt;
@@ -687,7 +687,7 @@
        unsigned long m;

        /* Round up to power-of-two size: see AR2305 note above */
-       bits_not_wanted =3D 1UL << get_iovp_order(bits_not_wanted << PAGE_S=
HIFT);
+       bits_not_wanted =3D 1UL << get_iovp_order(bits_not_wanted << iovp_s=
hift);
        for (; bits_not_wanted > 0 ; res_ptr++) {

                if (unlikely(bits_not_wanted > BITS_PER_LONG)) {




--=-zDHTSwAnqxJBI6Z07mgl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBiVZE6f3YPBUeVSgRAiUBAKDEH8P3PlnHFxY5uezMmTQsWmKR2gCbB3gR
d1zuLZHlyT3UFLHuUHnuKkA=
=aWD8
-----END PGP SIGNATURE-----

--=-zDHTSwAnqxJBI6Z07mgl--
