From: "Eric Gillespie, Jr." <epg@progeny.com>
Date: Tue, 18 Sep 2001 20:47:29 +0000
Subject: [Linux-ia64] Re: libgmp3 problem on IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Message-Id: <marc-linux-ia64-105590698805219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Eric Gillespie, Jr. <epg@progeny.com> writes:

> For the past couple days i have been investigating an odd segfault in
> Sawfish.  For some reason, some people were not seeing it, but once it
> starts, it is perfectly reproducable, even after eliminating any state
> Sawfish saves (Unix domain socket, configuration files, etc.).

Some co-workers started investigating this today, and found a patch from
Red Hat which apparently was not shared with bug-gmp.  Even with the
patch gmp still fails 19 out of 21 of its tests, so i'm not sure the
patch accomplishes much.  We're still investigating the issue.  Anyway,
i have attached the patch (by Philipp Knirsch <pknirsch@redhat.de>).

-- 
Eric Gillespie, Jr. <*> epg@progeny.com
Software Developer
Progeny Linux Systems - http://progeny.com
"I don't know what a Sawfish Window Manager is."

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gmp-3.1.1-ia64.patch"

diff -urN gmp-3.1.1/longlong.h gmp-3.1.1.new/longlong.h
--- gmp-3.1.1/longlong.h	Mon Jul 24 19:04:09 2000
+++ gmp-3.1.1.new/longlong.h	Mon Feb  5 15:39:18 2001
@@ -157,14 +157,14 @@
 #endif /* LONGLONG_STANDALONE */
 #endif /* hppa */
 
-#if defined (__ia64) && W_TYPE_SIZE == 64
+#if defined (__ia64) && !defined(NO_ASM) && W_TYPE_SIZE == 64
 #if defined (__GNUC__)
 #define umul_ppmm(ph, pl, m0, m1) \
   do {									\
     UDItype __m0 = (m0), __m1 = (m1);					\
     __asm__ ("xma.hu %0 = %1, %2, f0"					\
-	     : "=e" (ph)						\
-	     : "e" (m0), "e" (m1));					\
+	     : "=f" (ph)						\
+	     : "f" (m0), "f" (m1));					\
     (pl) = __m0 * __m1;							\
   } while (0)
 #endif
diff -urN gmp-3.1.1/mpn/Makefile.am gmp-3.1.1.new/mpn/Makefile.am
--- gmp-3.1.1/mpn/Makefile.am	Mon Jul 24 19:04:20 2000
+++ gmp-3.1.1.new/mpn/Makefile.am	Mon Feb  5 15:43:02 2001
@@ -36,7 +36,7 @@
 libmpn_la_LIBADD = $(OFILES)
 libmpn_la_DEPENDENCIES = $(OFILES)
 
-TARG_DIST = a29k alpha arm clipper cray generic hppa i960 lisp m68k m88k \
+TARG_DIST = a29k alpha arm clipper cray generic hppa i960 ia64 lisp m68k m88k \
   mips2 mips3 ns32k pa64 pa64w power powerpc32 powerpc64 pyr sh sparc32 \
   sparc64 thumb vax x86 z8000 z8000x
 
diff -urN gmp-3.1.1/mpn/ia64/gmp-mparam.h gmp-3.1.1.new/mpn/ia64/gmp-mparam.h
--- gmp-3.1.1/mpn/ia64/gmp-mparam.h	Thu Jan  1 01:00:00 1970
+++ gmp-3.1.1.new/mpn/ia64/gmp-mparam.h	Mon Feb  5 15:43:37 2001
@@ -0,0 +1,27 @@
+/* gmp-mparam.h -- Compiler/machine parameter header file.
+
+Copyright (C) 1991, 1993, 1994 Free Software Foundation, Inc.
+
+This file is part of the GNU MP Library.
+
+The GNU MP Library is free software; you can redistribute it and/or modify
+it under the terms of the GNU Lesser General Public License as published by
+the Free Software Foundation; either version 2.1 of the License, or (at your
+option) any later version.
+
+The GNU MP Library is distributed in the hope that it will be useful, but
+WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
+License for more details.
+
+You should have received a copy of the GNU Lesser General Public License
+along with the GNU MP Library; see the file COPYING.LIB.  If not, write to
+the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
+MA 02111-1307, USA. */
+
+#define BITS_PER_MP_LIMB 64
+#define BYTES_PER_MP_LIMB 8
+#define BITS_PER_LONGINT 64
+#define BITS_PER_INT 32
+#define BITS_PER_SHORTINT 16
+#define BITS_PER_CHAR 8

--M9NhX3UHpAaciwkO--

