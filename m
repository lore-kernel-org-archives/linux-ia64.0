From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 May 2001 07:39:36 +0000
Subject: [Linux-ia64] libc patch: update of memcpy et al
Message-Id: <marc-linux-ia64-105590693005639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below bring the performance of memcpy(), memmove(), bcopy(),
and bzero() up to more reasonable levels.  I haven't run this through
"make check", but I believe the changes to be OK.

Thanks,

	--david

ChangeLog

2001-05-22  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/ia64/memmove.S: Increase MEMLAT from 6 to 21 for better
	performance.
	* sysdeps/ia64/memcpy.S: Ditto.

	* sysdeps/ia64/bcopy.S: New file.

	* sysdeps/ia64/bzero.S: New file (derived from memset.S).

Index: sysdeps/ia64/memcpy.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memcpy.S,v
retrieving revision 1.6
diff -u -r1.6 memcpy.S
--- sysdeps/ia64/memcpy.S	2001/04/11 19:56:45	1.6
+++ sysdeps/ia64/memcpy.S	2001/05/22 07:32:57
@@ -68,10 +68,12 @@
 		br.ctop.sptk .loop##shift ;				\
 		br.cond.sptk .cpyfew ; /* deal with the remaining bytes */
 
+#define MEMLAT	21
+#define Nrot	(((2*MEMLAT+3) + 7) & ~7)
+
 ENTRY(memcpy)
 	.prologue
-	alloc 	r2 = ar.pfs, 3, 16 - 3, 0, 16
-#include "softpipe.h"
+	alloc 	r2 = ar.pfs, 3, Nrot - 3, 0, Nrot
 	.rotr	r[MEMLAT + 2], q[MEMLAT + 1]
 	.rotp	p[MEMLAT + 2]
 	mov	ret0 = in0		// return value = dest
Index: sysdeps/ia64/memmove.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memmove.S,v
retrieving revision 1.3
diff -u -r1.3 memmove.S
--- sysdeps/ia64/memmove.S	2001/04/11 19:56:45	1.3
+++ sysdeps/ia64/memmove.S	2001/05/22 07:32:57
@@ -67,10 +67,12 @@
 		br.ctop.sptk .loop##shift ;				\
 		br.cond.sptk .cpyfew ; /* deal with the remaining bytes */
 
-ENTRY(memmove)
+#define MEMLAT	21
+#define Nrot	(((2*MEMLAT+3) + 7) & ~7)
+
+ENTRY(__memmove)
 	.prologue
-	alloc 	r2 = ar.pfs, 3, 29, 0, 32
-#include "softpipe.h"
+	alloc 	r2 = ar.pfs, 3, Nrot - 3, 0, Nrot
 	.rotr	r[MEMLAT + 2], q[MEMLAT + 1]
 	.rotp	p[MEMLAT + 2]
 	mov	ret0 = in0		// return value = dest
@@ -235,6 +237,8 @@
 	data8	.loop56 - .loop40
 	data8	.loop56 - .loop48
 	data8	.loop56 - .loop56
+
+END(__memmove)
 
-END(memmove)
+weak_alias(__memmove, memmove)
--- /dev/null	Sat Mar 24 01:35:12 2001
+++ sysdeps/ia64/bcopy.S	Tue May 22 00:14:54 2001
@@ -0,0 +1,10 @@
+#include <sysdep.h>
+
+ENTRY(bcopy)
+	.regstk 3, 0, 0, 0
+	mov r8 = in0
+	mov in0 = in1
+	;;
+	mov in1 = r8
+	br.cond.sptk.many __memmove
+END(bcopy)
--- /dev/null	Sat Mar 24 01:35:12 2001
+++ sysdeps/ia64/bzero.S	Tue May 22 00:22:19 2001
@@ -0,0 +1,94 @@
+/* Optimized version of the standard bzero() function.
+   This file is part of the GNU C Library.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
+   Contributed by Dan Pop <Dan.Pop@cern.ch>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If not,
+   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+   Boston, MA 02111-1307, USA.  */
+
+/* Return: dest
+  
+   Inputs:
+        in0:    dest
+        in1:    count
+
+   The algorithm is fairly straightforward: set byte by byte until we
+   we get to a word aligned address, then set word by word as much as
+   possible; the remaining few bytes are set one by one.  */
+
+#include <sysdep.h>
+#undef ret
+
+#define dest		in0
+#define	cnt		in1
+
+#define save_pfs 	loc0
+#define ptr1		loc1
+#define ptr2		loc2
+#define tmp		loc3
+#define	loopcnt		loc4
+#define save_lc		loc5
+
+ENTRY(bzero)
+	.prologue
+	alloc	save_pfs = ar.pfs, 2, 6, 0, 0	
+	.save ar.lc, save_lc
+	mov	save_lc = ar.lc
+	.body
+	mov	ret0 = dest
+	and	tmp = 7, dest
+	cmp.eq	p6, p0 = cnt, r0
+(p6)	br.cond.spnt .restore_and_exit ;;
+	mov	ptr1 = dest
+	sub	loopcnt = 8, tmp
+	cmp.gt	p6, p0 = 16, cnt
+(p6)	br.cond.spnt .set_few;;
+	cmp.eq	p6, p0 = tmp, r0
+(p6)	br.cond.sptk .dest_aligned
+	sub	cnt = cnt, loopcnt
+	adds	loopcnt = -1, loopcnt;;
+	mov	ar.lc = loopcnt;;	
+.l1:
+	st1	[ptr1] = r0, 1
+	br.cloop.dptk	.l1 ;;
+.dest_aligned:
+	adds	ptr2 = 8, ptr1
+	shr.u	loopcnt = cnt, 4 ;;	// loopcnt = cnt / 16
+	cmp.eq	p6, p0 = loopcnt, r0
+(p6)	br.cond.spnt	.one_more
+	and	cnt = 0xf, cnt		// compute the remaining cnt
+	adds	loopcnt = -1, loopcnt;;
+	mov     ar.lc = loopcnt;;	
+.l2:
+	st8	[ptr1] = r0, 16
+	st8	[ptr2] = r0, 16
+	br.cloop.dptk .l2
+	cmp.le	p6, p0 = 8, cnt	;;
+.one_more:
+(p6)	st8     [ptr1] = r0, 8
+(p6)	adds	cnt = -8, cnt ;;
+	cmp.eq	p6, p0 = cnt, r0
+(p6)	br.cond.spnt	.restore_and_exit
+.set_few:
+	adds	loopcnt = -1, cnt;;
+	mov	ar.lc = loopcnt;;
+.l3:	
+	st1     [ptr1] = r0, 1
+	br.cloop.dptk   .l3 ;;	
+.restore_and_exit:
+	mov	ar.lc = save_lc
+	mov	ar.pfs = save_pfs
+	br.ret.sptk.many b0					
+END(bzero)

