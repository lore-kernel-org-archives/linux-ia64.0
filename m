From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 03 May 2006 18:46:07 +0000
Subject: RE: strcpy returns NULL pointer and not destination pointer
Message-Id: <4t16i2$tj9fu@orsmga001.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060503133806.GC19859@localhost>
In-Reply-To: <20060503133806.GC19859@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bob Picco wrote on Wednesday, May 03, 2006 11:31 AM
> Chen, Kenneth W wrote:	[Wed May 03 2006, 02:08:47PM EDT]
> > Bob Picco wrote on Wednesday, May 03, 2006 6:38 AM
> > > The removal of -ffreestanding compiler flag in 2.6.17-rcX (commit id
> > > 6edfba1b33c701108717f4e036320fc39abe1912) causes strcpy calls=20
> > > with a known size for the source string to be replaced with memcpy wh=
ich
> > > is faster.  ia64 memcpy has return values which are unlike stdlibc and
> > > the other arch memcpy routines examined by me in the kernel.  The ia6=
4 return
> > > values are 0 for success and number of bytes copied for failure. Thus=
 any
> > > instance of pointer =3D strcpy(dest, "some string") has zero assigned=
 to
> > > pointer.  I detected this when testing kgdb on 2.6.17-rc3. =20
> > >=20
> > > The implementation in memcpy_mck.S doesn't leave a single scratch
> > > register or predicate. I didn't pursue very long for a solution.
> >=20
> > I thought I fixed that about 3 years ago:
> >=20
> > http://marc.theaimsgroup.com/?l=3Dlinux-ia64&m=105590709805435&w=3D2
> >=20
> > Did it fall through the crack?  I'm not sure what's going on.
>=20
> It looks to have definitely fallen through a crack or two.
>=20
> I applied to rc3 and boot tested for you. I assume you'll post patch agai=
n.

Wow, 3 years ago patch still applies.  I'm impressed, that doesn't happen
very often ;-)

Here is an updated version, with comments updated (bcopy was removed).




[patch] fix return value of memcpy

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/lib/memcpy_mck.S.orig	2006-03-19 21:53:29.000000000 -0800
+++ ./arch/ia64/lib/memcpy_mck.S	2006-05-03 12:30:20.000000000 -0700
@@ -6,7 +6,9 @@
  *	in1:	source address
  *	in2:	number of bytes to copy
  * Output:
- * 	0 if success, or number of byte NOT copied if error occurred.
+ *	for memcpy:    retrun dest
+ * 	for copy_user: return 0 if success,
+ *		       or number of byte NOT copied if error occurred.
  *
  * Copyright (C) 2002 Intel Corp.
  * Copyright (C) 2002 Ken Chen <kenneth.w.chen@intel.com>
@@ -73,6 +75,7 @@ GLOBAL_ENTRY(memcpy)
 	and	r28=3D0x7,in0
 	and	r29=3D0x7,in1
 	mov	f6=F0
+	mov	retval=3Din0
 	br.cond.sptk .common_code
 	;;
 END(memcpy)
@@ -84,7 +87,7 @@ GLOBAL_ENTRY(__copy_user)
 	mov	f6=F1
 	mov	saved_in0=3Din0	// save dest pointer
 	mov	saved_in1=3Din1	// save src pointer
-	mov	saved_in2=3Din2	// save len
+	mov	retval=3Dr0	// initialize return value
 	;;
 .common_code:
 	cmp.gt	p15,p0=3D8,in2	// check for small size
@@ -92,7 +95,7 @@ GLOBAL_ENTRY(__copy_user)
 	cmp.ne	p14,p0=3D0,r29	// check src alignment
 	add	src0=3D0,in1
 	sub	r30=3D8,r28	// for .align_dest
-	mov	retval=3Dr0	// initialize return value
+	mov	saved_in2=3Din2	// save len
 	;;
 	add	dst0=3D0,in0
 	add	dst1=3D1,in0	// dest odd index
