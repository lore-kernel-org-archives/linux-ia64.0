From: Linus Torvalds <torvalds@osdl.org>
Date: Tue, 17 Feb 2004 23:53:05 +0000
Subject: Re: radeon warning on 64-bit platforms
Message-Id: <Pine.LNX.4.58.0402171552140.2154@home.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.35199.597235.894615@napali.hpl.hp.com>
 <1077054385.2714.72.camel@thor.asgaard.local> <16434.36137.623311.751484@napali.hpl.hp.com>
 <1077055209.2712.80.camel@thor.asgaard.local> <16434.37025.840577.826949@napali.hpl.hp.com>
 <1077058106.2713.88.camel@thor.asgaard.local> <16434.41884.249541.156083@napali.hpl.hp.com>
In-Reply-To: <16434.41884.249541.156083@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: davidm@hpl.hp.com
Cc: Michel =?ISO-8859-1?Q?D=E4nzer?= <michel@daenzer.net>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org



On Tue, 17 Feb 2004, David Mosberger wrote:
>=20
> Here is a proposed patch for fixing the compile-warning that shows up
> when compiling radeon_state.c on a 64-bit platform (Itanium, in my
> case).

How about this alternate edited one that gets indentation right
and is more explicit about what's going on? Does this work for you?

		Linus

---
=3D=3D=3D drivers/char/drm/radeon_state.c 1.23 vs edited =3D=3D--- 1.23/dri=
vers/char/drm/radeon_state.c	Tue Feb  3 21:29:26 2004
+++ edited/drivers/char/drm/radeon_state.c	Tue Feb 17 15:51:53 2004
@@ -2185,10 +2185,21 @@
 	case RADEON_PARAM_STATUS_HANDLE:
 		value =3D dev_priv->ring_rptr_offset;
 		break;
+#if BITS_PER_LONG =3D 32
+	/*
+	 * This ioctl() doesn't work on 64-bit platforms because hw_lock is a
+	 * pointer which can't fit into an int-sized variable.  According to
+	 * Michel D=E4nzer, the ioctl() is only used on embedded platforms, so not
+	 * supporting it shouldn't be a problem.  If the same functionality is
+	 * needed on 64-bit platforms, a new ioctl() would have to be added, so
+	 * backwards-compatibility for the embedded platforms can be maintained.
+	 *      --davidm 4-Feb-2004.
+	 */
 	case RADEON_PARAM_SAREA_HANDLE:
 		/* The lock is the first dword in the sarea. */
 		value =3D (int)dev->lock.hw_lock;=20
 		break;=09
+#endif
 	case RADEON_PARAM_GART_TEX_HANDLE:
 		value =3D dev_priv->gart_textures_offset;
 		break;
