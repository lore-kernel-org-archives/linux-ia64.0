From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 00:51:24 +0000
Subject: Re: radeon warning on 64-bit platforms
Message-Id: <16434.46860.429861.157242@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16434.35199.597235.894615@napali.hpl.hp.com>
	<1077054385.2714.72.camel@thor.asgaard.local>
	<16434.36137.623311.751484@napali.hpl.hp.com>
	<1077055209.2712.80.camel@thor.asgaard.local>
	<16434.37025.840577.826949@napali.hpl.hp.com>
	<1077058106.2713.88.camel@thor.asgaard.local>
	<16434.41884.249541.156083@napali.hpl.hp.com>
	<20040217234848.GB22534@krispykreme>
In-Reply-To: <20040217234848.GB22534@krispykreme>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: torvalds@osdl.org, Michel D?nzer <michel@daenzer.net>, Anton Blanchard <anton@samba.org>
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 10:48:49 +1100, Anton Blanchard <anton@samba.org>=
 said:

  Anton> A small thing, could the comment be constrained to 80
  Anton> columns? :)

I don't really see the point of that, given that pretty much all
existing Linux source code is formatted for 100 columns.  I don't feel
strongly about it, however, so I changed it.

>>>>> On Tue, 17 Feb 2004 15:53:05 -0800 (PST), Linus Torvalds <torvalds@os=
dl.org> said:

  Linus> How about this alternate edited one that gets indentation
  Linus> right and is more explicit about what's going on? Does this
  Linus> work for you?

Fine by me.

>>>>> On Wed, 18 Feb 2004 00:44:16 +0100, Michel D=E4nzer <michel@daenzer.n=
et> said:

  Michel> looks good to me, except for a detail:

  >> + * Michael D=E4nzer, the ioctl() is only used on embedded
  >> platforms, so not

  Michel> ^^^^^^^ That's not quite my first name. :)

Sorry about that, fixed below (or so I hope).

	--david

=3D=3D=3D drivers/char/drm/radeon_state.c 1.23 vs edited =3D=3D--- 1.23/dri=
vers/char/drm/radeon_state.c	Tue Feb  3 21:29:26 2004
+++ edited/drivers/char/drm/radeon_state.c	Tue Feb 17 16:49:15 2004
@@ -2185,10 +2185,21 @@
 	case RADEON_PARAM_STATUS_HANDLE:
 		value =3D dev_priv->ring_rptr_offset;
 		break;
+#if BITS_PER_LONG =3D 32
+	/*
+	 * This ioctl() doesn't work on 64-bit platforms because hw_lock is a
+	 * pointer which can't fit into an int-sized variable.  According to
+	 * Michel D=E4nzer, the ioctl() is only used on embedded platforms, so
+	 * not supporting it shouldn't be a problem.  If the same functionality
+	 * is needed on 64-bit platforms, a new ioctl() would have to be added,
+	 * so backwards-compatibility for the embedded platforms can be
+	 * maintained.  --davidm 4-Feb-2004.
+	 */
 	case RADEON_PARAM_SAREA_HANDLE:
 		/* The lock is the first dword in the sarea. */
-		value =3D (int)dev->lock.hw_lock;=20
-		break;=09
+		value =3D (long)dev->lock.hw_lock;
+		break;
+#endif
 	case RADEON_PARAM_GART_TEX_HANDLE:
 		value =3D dev_priv->gart_textures_offset;
 		break;
