From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 03 May 2006 18:53:43 +0000
Subject: RE: strcpy returns NULL pointer and not destination pointer
Message-Id: <4t16i2$tjcpe@orsmga001.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060503133806.GC19859@localhost>
In-Reply-To: <20060503133806.GC19859@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote on Wednesday, May 03, 2006 11:49 AM
> On Wed, May 03, 2006 at 11:46:07AM -0700, Chen, Kenneth W wrote:
> > - * 	0 if success, or number of byte NOT copied if error occurred.
> > + *	for memcpy:    retrun dest
>=20
> typo


Thank you.  I need a spell-o-matic checker :-)



[patch] fix return value of memcpy

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/lib/memcpy_mck.S.orig	2006-03-19 21:53:29.000000000 -0800
+++ ./arch/ia64/lib/memcpy_mck.S	2006-05-03 12:30:20.000000000 -0700
@@ -6,7 +6,9 @@
  *	in1:	source address
  *	in2:	number of bytes to copy
  * Output:
- * 	0 if success, or number of byte NOT copied if error occurred.
+ *	for memcpy:    return dest
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
