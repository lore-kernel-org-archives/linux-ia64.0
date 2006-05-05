From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 May 2006 20:04:40 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200605052004.k45K4et7005237@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/lib/memcpy_mck.S |    9 ++++++---
 include/asm-ia64/bitops.h  |    1 -
 2 files changed, 6 insertions(+), 4 deletions(-)

Chen, Kenneth W:
      [IA64] strcpy returns NULL pointer and not destination pointer

Jon Mason:
      [IA64] remove asm-ia64/bitops.h self-inclusion

diff-tree 913ed41eb5c948d2f8b5deffd29c2638eceef3d7 (from 3e6e155646706f1ef9=
f791a4402d145f112a3f8d)
Author: Jon Mason <jdmason@us.ibm.com>
Date:   Wed May 3 17:26:58 2006 -0500

    [IA64] remove asm-ia64/bitops.h self-inclusion
   =20
    asm-ia64/bitops.h includes itself.  The #ifndef _ASM_IA64_BITOPS_H
    prevents this from being an issue, but it should still be removed.
   =20
    Signed-off-by: Jon Mason <jdmason@us.ibm.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/bitops.h b/include/asm-ia64/bitops.h
index 90921e1..6cc517e 100644
--- a/include/asm-ia64/bitops.h
+++ b/include/asm-ia64/bitops.h
@@ -11,7 +11,6 @@ #define _ASM_IA64_BITOPS_H
=20
 #include <linux/compiler.h>
 #include <linux/types.h>
-#include <asm/bitops.h>
 #include <asm/intrinsics.h>
=20
 /**

diff-tree 3e6e155646706f1ef9f791a4402d145f112a3f8d (from d98550e334715b2d9e=
45f8f0f4e1608720108640)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Wed May 3 11:53:43 2006 -0700

    [IA64] strcpy returns NULL pointer and not destination pointer
   =20
    Bob Picco noted that 6edfba1b33c701108717f4e036320fc39abe1912
    dropped the -ffreestanding compiler flag from the top level
    Makefile, which allows the compiler to substitute memcpy() in
    places where strcpy() is used with a known size source string.
    But the ia64 memcpy() returns 0 for success, and "bytes copied"
    for failure.
   =20
    Fix to return the address of the destination string (like
    stdlibc version, and other architectures).  There are no
    places where ia64 specific code makes use of the non-standard
    return value.
   =20
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/lib/memcpy_mck.S b/arch/ia64/lib/memcpy_mck.S
index 46c9331..9e534d5 100644
--- a/arch/ia64/lib/memcpy_mck.S
+++ b/arch/ia64/lib/memcpy_mck.S
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
