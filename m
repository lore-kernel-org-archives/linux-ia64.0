From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 11 Apr 2001 19:11:49 +0000
Subject: [Linux-ia64] libc patch: add unwind directives to str*/mem*
Message-Id: <marc-linux-ia64-105590693005392@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a patch to add unwind directives to the str* and mem*
routines.  It also cleans up a few minor things (see ChangeLog for
details).  The string/ and inet/ testsuites still run fine after
applying this patch (I couldn't run the entire suite because I'm still
using the Nov 17 compiler...).

	--david

2001-04-11  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/ia64/htonl.S: Drop superfluous "alloc".
	* sysdeps/ia64/htons.S: Ditto.

	* sysdeps/ia64/memset.S: Add unwind directives.
	* sysdeps/ia64/strncpy.S: Likewise.

	* sysdeps/ia64/memccpy.S: Add unwind directives.  Drop superfluous
	restore of ar.pfs.
	* sysdeps/ia64/strchr.S: Likewise.
	* sysdeps/ia64/memmove.S: Likewise.
	* sysdeps/ia64/memcpy.S: Likewise.
	* sysdeps/ia64/memcmp.S: Likewise.
	* sysdeps/ia64/memchr.S: Likewise.
	* sysdeps/ia64/strcmp.S: Likewise.
	* sysdeps/ia64/strlen.S: Likewise.
	* sysdeps/ia64/strcpy.S: Likewise.

Index: sysdeps/ia64/_mcount.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/_mcount.S,v
retrieving revision 1.3
diff -u -r1.3 _mcount.S
--- sysdeps/ia64/_mcount.S	2001/03/25 05:08:20	1.3
+++ sysdeps/ia64/_mcount.S	2001/04/11 19:06:42
@@ -1,5 +1,5 @@
 /* Machine-specific calling sequence for `mcount' profiling function.  ia64
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
      Contributed by David Mosberger <davidm@hpl.hp.com>
    This file is part of the GNU C Library.
 
Index: sysdeps/ia64/htonl.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/htonl.S,v
retrieving revision 1.1
diff -u -r1.1 htonl.S
--- sysdeps/ia64/htonl.S	2000/06/30 17:44:46	1.1
+++ sysdeps/ia64/htonl.S	2001/04/11 19:06:42
@@ -1,5 +1,5 @@
 /* Change byte order in 32-bit value.  ia64 version.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by Dan Pop <Dan.Pop@cern.ch>
 
@@ -20,14 +20,12 @@
 
 
 #include <sysdep.h>
-#undef ret
 
 ENTRY(htonl)
-	alloc	ret0 = ar.pfs, 1, 0, 0, 0
-	shl	in0 = in0, 32
+	shl	ret0 = r32, 32
 	;;
-	mux1	ret0 = in0, @rev
-	br.ret.sptk.many b0
+	mux1	ret0 = ret0, @rev
+	ret
 END(htonl)
 
 weak_alias (htonl, ntohl)
Index: sysdeps/ia64/htons.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/htons.S,v
retrieving revision 1.1
diff -u -r1.1 htons.S
--- sysdeps/ia64/htons.S	2000/06/30 17:45:02	1.1
+++ sysdeps/ia64/htons.S	2001/04/11 19:06:42
@@ -1,5 +1,5 @@
 /* Change byte order in 16-bit value.  ia64 version.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by Dan Pop <Dan.Pop@cern.ch>
 
@@ -20,14 +20,12 @@
 
 
 #include <sysdep.h>
-#undef ret
 
 ENTRY(htons)
-	alloc	ret0 = ar.pfs, 1, 0, 0, 0
-	shl	in0 = in0, 48
+	shl	ret0 = r32, 48
 	;;
-	mux1	ret0 = in0, @rev
-	br.ret.sptk.many b0
+	mux1	ret0 = ret0, @rev
+	ret
 END(htons)
 
 weak_alias (htons, ntohs)
Index: sysdeps/ia64/memccpy.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memccpy.S,v
retrieving revision 1.3
diff -u -r1.3 memccpy.S
--- sysdeps/ia64/memccpy.S	2000/09/09 08:02:03	1.3
+++ sysdeps/ia64/memccpy.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the memccpy() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -37,7 +37,6 @@
 #define OP_T_THRES 	16
 #define OPSIZ 		8
 
-#define saved_pfs	r14
 #define saved_pr	r17
 #define saved_lc	r18
 #define dest		r19
@@ -53,15 +52,19 @@
 #define	value		r31
 
 ENTRY(memccpy)
-	alloc 	saved_pfs = ar.pfs, 4, 40 - 4, 0, 40
+	.prologue
+	alloc 	r2 = ar.pfs, 4, 40 - 4, 0, 40
 
 #include "softpipe.h"
 	.rotr	r[MEMLAT + 3], tmp1[4], tmp2[4], val[4], tmp3[2], pos0[2]
 	.rotp	p[MEMLAT + 6 + 1]
 
 	mov	ret0 = r0		// return NULL if no match
+	.save pr, saved_pr
 	mov	saved_pr = pr		// save the predicate registers
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc	// save the loop counter
+	.body
 	mov 	dest = in0		// dest
 	mov 	src = in1		// src
 	extr.u	char = in2, 0, 8	// char
@@ -143,7 +146,6 @@
 .foundit:
 (p6)	mov	ret0 = dest
 .restore_and_exit:
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov     pr = saved_pr, -1    	// restore the predicate registers
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
@@ -158,7 +160,6 @@
 	shr.u	value = value, 8
 	br.cloop.sptk .l5 ;;
 	mov 	ret0 = dest
-	mov	ar.pfs = saved_pfs
 	mov	pr = saved_pr, -1
 	mov	ar.lc = saved_lc
 	br.ret.sptk.many b0
Index: sysdeps/ia64/memchr.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memchr.S,v
retrieving revision 1.5
diff -u -r1.5 memchr.S
--- sysdeps/ia64/memchr.S	2000/09/09 08:02:45	1.5
+++ sysdeps/ia64/memchr.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the standard memchr() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -43,7 +43,6 @@
 #include <sysdep.h>
 #undef ret
 
-#define	saved_pfs	r14
 #define saved_pr	r15
 #define saved_lc	r16
 #define	chr		r17
@@ -57,12 +56,16 @@
 #define str		in0
 
 ENTRY(__memchr)
-	alloc saved_pfs = ar.pfs, 3, 0, 29, 32
+	.prologue
+	alloc r2 = ar.pfs, 3, 0, 29, 32
 #include "softpipe.h"
 	.rotr	value[MEMLAT+1], addr[MEMLAT+3], aux[2], poschr[2]
 	.rotp	p[MEMLAT+3]
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc 	// save the loop counter
+	.save pr, saved_pr
 	mov	saved_pr = pr		// save the predicates
+	.body
 	mov 	ret0 = str
 	and 	tmp = 7, str		// tmp = str % 8
 	cmp.ne	p7, p0 = r0, r0		// clear p7
@@ -118,7 +121,6 @@
 (p6)	adds	ret0 = -1, ret0 		   // if we got here from l1 or l3
 (p7)	add	ret0 = addr[MEMLAT+2], poschr[1]   // if we got here from l2
 	mov	pr = saved_pr, -1
-	mov	ar.pfs = saved_pfs
 	mov	ar.lc = saved_lc
 	br.ret.sptk.many b0
 
Index: sysdeps/ia64/memcmp.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memcmp.S,v
retrieving revision 1.2
diff -u -r1.2 memcmp.S
--- sysdeps/ia64/memcmp.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/memcmp.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the standard memcmp() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -40,7 +40,6 @@
 #define OPSIZ 		8
 #define MEMLAT		2
 
-#define saved_pfs	r14
 #define start		r15
 #define saved_pr	r17
 #define saved_lc	r18
@@ -56,14 +55,18 @@
 #define loopcnt		r30
 
 ENTRY(memcmp)
-	alloc 	saved_pfs = ar.pfs, 3, 37, 0, 40
+	.prologue
+	alloc 	r2 = ar.pfs, 3, 37, 0, 40
 
 	.rotr	r[MEMLAT + 2], q[MEMLAT + 5], tmp1[4], tmp2[4], val[2]
 	.rotp	p[MEMLAT + 4 + 1]
 
 	mov	ret0 = r0		// by default return value = 0
+	.save pr, saved_pr
 	mov	saved_pr = pr		// save the predicate registers
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc	// save the loop counter
+	.body
 	mov 	dest = in0		// dest
 	mov 	src = in1		// src
 	mov	len = in2		// len
@@ -126,7 +129,6 @@
 	cmp.ltu	p6, p7 = value2, value1 ;;
 (p6)	mov	ret0 = -1
 (p7)	mov	ret0 = 1
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov     pr = saved_pr, -1    	// restore the predicate registers
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
@@ -154,7 +156,6 @@
 .done:
 (p6)	sub	ret0 = value2, value1	// don't execute it if falling thru
 .restore_and_exit:
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov     pr = saved_pr, -1    	// restore the predicate registers
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
Index: sysdeps/ia64/memcpy.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memcpy.S,v
retrieving revision 1.5
diff -u -r1.5 memcpy.S
--- sysdeps/ia64/memcpy.S	2000/06/30 18:32:47	1.5
+++ sysdeps/ia64/memcpy.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the standard memcpy() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -40,7 +40,6 @@
 #define OP_T_THRES 	16
 #define OPSIZ 		8
 
-#define saved_pfs	r14
 #define adest		r15
 #define saved_pr	r17
 #define saved_lc	r18
@@ -70,13 +69,17 @@
 		br.cond.sptk .cpyfew ; /* deal with the remaining bytes */
 
 ENTRY(memcpy)
-	alloc 	saved_pfs = ar.pfs, 3, 16 - 3, 0, 16
+	.prologue
+	alloc 	r2 = ar.pfs, 3, 16 - 3, 0, 16
 #include "softpipe.h"
 	.rotr	r[MEMLAT + 2], q[MEMLAT + 1]
 	.rotp	p[MEMLAT + 2]
 	mov	ret0 = in0		// return value = dest
+	.save pr, saved_pr
 	mov	saved_pr = pr		// save the predicate registers
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc	// save the loop counter
+	.body
 	or	tmp3 = in0, in1 ;;	// tmp3 = dest | src
 	or	tmp3 = tmp3, in2	// tmp3 = dest | src | len
 	mov 	dest = in0		// dest
@@ -112,7 +115,6 @@
 (p[MEMLAT])	st8	[adest] = q[MEMLAT], 16
 		br.ctop.dptk .l0 ;;
 
-	mov	ar.pfs = saved_pfs	// restore the PFS
 	mov	pr = saved_pr, -1	// restore the predicate registers
 	mov	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
@@ -182,7 +184,6 @@
 	st1	[dest] = value, 1
 	br.cloop.dptk	.l4 ;;
 .restore_and_exit:
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov     pr = saved_pr, -1    	// restore the predicate registers
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
Index: sysdeps/ia64/memmove.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memmove.S,v
retrieving revision 1.2
diff -u -r1.2 memmove.S
--- sysdeps/ia64/memmove.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/memmove.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the standard memmove() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -39,7 +39,6 @@
 #define OP_T_THRES 	16
 #define OPSIZ 		 8
 
-#define saved_pfs	r14
 #define adest		r15
 #define saved_pr	r17
 #define saved_lc	r18
@@ -69,13 +68,17 @@
 		br.cond.sptk .cpyfew ; /* deal with the remaining bytes */
 
 ENTRY(memmove)
-	alloc 	saved_pfs = ar.pfs, 3, 29, 0, 32
+	.prologue
+	alloc 	r2 = ar.pfs, 3, 29, 0, 32
 #include "softpipe.h"
 	.rotr	r[MEMLAT + 2], q[MEMLAT + 1]
 	.rotp	p[MEMLAT + 2]
 	mov	ret0 = in0		// return value = dest
+	.save pr, saved_pr
 	mov	saved_pr = pr		// save the predicate registers
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc	// save the loop counter
+	.body
 	or	tmp3 = in0, in1 ;;	// tmp3 = dest | src
 	or	tmp3 = tmp3, in2	// tmp3 = dest | src | len
 	mov 	dest = in0		// dest
@@ -119,7 +122,6 @@
 (p[MEMLAT])	st8	[adest] = q[MEMLAT], 16
 		br.ctop.dptk .l0 ;;
 
-	mov	ar.pfs = saved_pfs	// restore the PFS
 	mov	pr = saved_pr, -1	// restore the predicate registers
 	mov	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
@@ -189,7 +191,6 @@
 	st1	[dest] = value, 1
 	br.cloop.dptk	.l4 ;;
 .restore_and_exit:
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov     pr = saved_pr, -1    	// restore the predicate registers
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
Index: sysdeps/ia64/memset.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/memset.S,v
retrieving revision 1.2
diff -u -r1.2 memset.S
--- sysdeps/ia64/memset.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/memset.S	2001/04/11 19:06:42
@@ -1,6 +1,6 @@
 /* Optimized version of the standard memset() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -45,8 +45,11 @@
 #define wordval		loc6
 
 ENTRY(memset)
+	.prologue
 	alloc	save_pfs = ar.pfs, 3, 7, 0, 0	
+	.save ar.lc, save_lc
 	mov	save_lc = ar.lc
+	.body
 	mov	ret0 = dest
 	and	tmp = 7, dest
 	cmp.eq	p6, p0 = cnt, r0
Index: sysdeps/ia64/strcat.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strcat.S,v
retrieving revision 1.2
diff -u -r1.2 strcat.S
--- sysdeps/ia64/strcat.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strcat.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* IA-64 assembly version of the standard strcat() function.  
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -37,14 +37,16 @@
 
 #define src	in1
 #define dest	in0
-#define save_pfs loc0
-#define save_b0	loc1
+#define save_b0	loc0
+#define save_pfs loc1
 #define tmp	loc2
 #define rc	ret0
 
 ENTRY(strcat)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
 	alloc 	save_pfs = ar.pfs, 2, 3, 2, 0
 	mov	save_b0 = b0
+	.body
 	mov	out0 = dest
 	mov	tmp = gp ;;
 	br.call.sptk.many b0 = strlen# ;; // rc = strlen(dest);
Index: sysdeps/ia64/strchr.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strchr.S,v
retrieving revision 1.2
diff -u -r1.2 strchr.S
--- sysdeps/ia64/strchr.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strchr.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strchr() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -33,7 +33,6 @@
 #include <sysdep.h>
 #undef ret
 
-#define	saved_pfs	r14
 #define saved_lc	r18
 #define poschr		r19
 #define pos0		r20
@@ -47,8 +46,11 @@
 #define chr		in1
 
 ENTRY(strchr)
-	alloc saved_pfs = ar.pfs, 2, 0, 0, 0
+	.prologue
+	alloc r2 = ar.pfs, 2, 0, 0, 0
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc 	// save the loop counter
+	.body
 	mov 	ret0 = str	
 	and 	tmp = 7, str		// tmp = str % 8
 	mux1	chrx8 = chr, @brcst
@@ -94,12 +96,10 @@
 	adds	ret0 = -15, ret0 ;;	// should be -16, but we decrement
 .restore_and_exit:			// ret0 in the next instruction
 	adds	ret0 = -1, ret0		// ret0 was pointing 1 char too far
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	br.ret.sptk.many b0
 .notfound:
 	mov	ret0 = r0		// return NULL if null was found
-	mov 	ar.pfs = saved_pfs	// first
 	mov 	ar.lc = saved_lc
 	br.ret.sptk.many b0
 .recovery:
Index: sysdeps/ia64/strcmp.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strcmp.S,v
retrieving revision 1.2
diff -u -r1.2 strcmp.S
--- sysdeps/ia64/strcmp.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strcmp.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strcmp() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -33,13 +33,12 @@
 #define s1		in0
 #define s2		in1
 
-#define saved_pfs	r14
 #define val1		r15
 #define val2		r16
 
 
 ENTRY(strcmp)
-	alloc	saved_pfs = ar.pfs, 2, 0, 0, 0
+	alloc	r2 = ar.pfs, 2, 0, 0, 0
 .loop:
 	ld1	val1 = [s1], 1
 	ld1	val2 = [s2], 1
@@ -50,6 +49,5 @@
 	cmp.eq.and p6, p0 = val1, val2
 (p6)	br.cond.sptk .loop
 	sub	ret0 = val1, val2
-	mov	ar.pfs = saved_pfs
 	br.ret.sptk.many b0
 END(strcmp)
Index: sysdeps/ia64/strcpy.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strcpy.S,v
retrieving revision 1.3
diff -u -r1.3 strcpy.S
--- sysdeps/ia64/strcpy.S	2000/12/07 05:22:02	1.3
+++ sysdeps/ia64/strcpy.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strcpy() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -34,7 +34,6 @@
 #include <sysdep.h>
 #undef ret
 
-#define saved_pfs	r14
 #define saved_lc	r15
 #define saved_pr	r16
 #define thresh		r17
@@ -53,15 +52,19 @@
 #define	value		r31
 
 ENTRY(strcpy)
-	alloc 	saved_pfs = ar.pfs, 2, 0, 30, 32
+	.prologue
+	alloc 	r2 = ar.pfs, 2, 0, 30, 32
 
 #define MEMLAT 2
 	.rotr	r[MEMLAT + 2]
 	.rotp	p[MEMLAT + 1]
 
 	mov	ret0 = in0		// return value = dest
+	.save pr, saved_pr
 	mov	saved_pr = pr           // save the predicate registers
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc	// save the loop counter
+	.body
 	sub	tmp = r0, in0 ;;	// tmp = -dest
 	mov 	dest = in0		// dest
 	mov 	src = in1		// src
@@ -127,7 +130,6 @@
 	st1	[dest] = c, 1
 	br.cloop.dptk	.l4 ;;
 .restore_and_exit:
-	mov 	ar.pfs = saved_pfs	// restore the PFS
 	mov 	ar.lc = saved_lc	// restore the loop counter
 	mov	pr = saved_pr, -1	// restore the predicate registers
 	br.ret.sptk.many b0
Index: sysdeps/ia64/strlen.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strlen.S,v
retrieving revision 1.2
diff -u -r1.2 strlen.S
--- sysdeps/ia64/strlen.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strlen.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strlen() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -36,7 +36,6 @@
 #include <sysdep.h>
 #undef ret
 
-#define	saved_pfs	r14
 #define saved_lc	r18
 #define str		r19
 #define pos0		r20
@@ -48,8 +47,11 @@
 #define len		ret0
 
 ENTRY(strlen)
-	alloc saved_pfs = ar.pfs, 1, 0, 0, 0
+	.prologue
+	alloc r2 = ar.pfs, 1, 0, 0, 0
+	.save ar.lc, saved_lc
         mov 	saved_lc = ar.lc 	// save the loop counter
+	.body
 	mov 	str = in0	
 	mov 	len = r0		// len = 0
 	and 	tmp = 7, in0		// tmp = str % 8
@@ -86,7 +88,6 @@
 	add	len = len, tmp;;
 	adds	len = -16, len
 .restore_and_exit:
-	mov ar.pfs = saved_pfs		// restore the PFS
 	mov ar.lc = saved_lc		// restore the loop counter
 	br.ret.sptk.many b0
 .recovery:
Index: sysdeps/ia64/strncmp.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strncmp.S,v
retrieving revision 1.2
diff -u -r1.2 strncmp.S
--- sysdeps/ia64/strncmp.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strncmp.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strncmp() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -35,13 +35,12 @@
 #define s2		in1
 #define n		in2
 
-#define saved_pfs	r14
 #define val1		r15
 #define val2		r16
 
 
 ENTRY(strncmp)
-	alloc	saved_pfs = ar.pfs, 3, 0, 0, 0
+	alloc	r2 = ar.pfs, 3, 0, 0, 0
 	mov	ret0 = r0
 	cmp.eq  p6, p0 = r0, r0		// set p6
 	cmp.eq	p7, p0 = n, r0		// return immediately if n = 0
@@ -58,6 +57,5 @@
 (p6)	br.cond.sptk .loop
 	sub	ret0 = val1, val2
 .restore_and_exit:
-	mov	ar.pfs = saved_pfs
 	br.ret.sptk.many b0
 END(strncmp)	
Index: sysdeps/ia64/strncpy.S
=================================RCS file: /cvs/glibc/libc/sysdeps/ia64/strncpy.S,v
retrieving revision 1.2
diff -u -r1.2 strncpy.S
--- sysdeps/ia64/strncpy.S	2000/05/21 21:56:19	1.2
+++ sysdeps/ia64/strncpy.S	2001/04/11 19:06:43
@@ -1,6 +1,6 @@
 /* Optimized version of the standard strncpy() function.
    This file is part of the GNU C Library.
-   Copyright (C) 2000 Free Software Foundation, Inc.
+   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
    Contributed by Dan Pop <Dan.Pop@cern.ch>.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -33,8 +33,8 @@
 #include <sysdep.h>
 #undef ret
 
-#define saved_pfs	loc0
-#define saved_b0	loc1
+#define saved_b0	loc0
+#define saved_pfs	loc1
 #define saved_pr	loc2
 #define saved_lc	loc3
 #define tmp		loc4
@@ -47,10 +47,14 @@
 #define rc		ret0
 
 ENTRY(strncpy)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3)
 	alloc 	saved_pfs = ar.pfs, 3, 6, 3, 0
 	mov	saved_b0 = b0
+	.save pr, saved_pr
 	mov	saved_pr = pr
+	.save ar.lc, saved_lc
 	mov	saved_lc = ar.lc
+	.body
 	cmp.gtu	p6, p0 = 24, n
 (p6)	br.cond.spnt .cpyfew
 	mov	out0 = src

