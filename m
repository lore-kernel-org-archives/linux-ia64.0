From: Keith Owens <kaos@sgi.com>
Date: Mon, 04 Oct 2004 06:25:22 +0000
Subject: [patch 1/5 salinfo-0.6] cleanup
Message-Id: <11341.1096871122@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

cleanup         Remove some dead code from salinfo 0.5, mainly from SuSE

Index: salinfo-0.5/Makefile
=================================--- salinfo-0.5.orig/Makefile	Mon Nov 24 16:27:34 2003
+++ salinfo-0.5/Makefile	Wed Sep 15 16:21:10 2004
@@ -14,10 +14,10 @@ clean:
 	rm -f salinfo_decode salinfo_decode_oem *.o
 
 install: salinfo_decode
-	mkdir -p $(mandir)/man8
+	mkdir -p $(prefix)$(mandir)/man8
 	mkdir -p $(prefix)$(crondir) $(prefix)$(sbindir) $(prefix)$(initdir)
 	mkdir -p $(prefix)$(logdir) $(prefix)$(logdir)/raw $(prefix)$(logdir)/decoded
-	cp -a salinfo_decode.8 $(mandir)/man8
+	cp -a salinfo_decode.8 $(prefix)$(mandir)/man8
 	cp -a salinfo_decode salinfo_decode_all $(prefix)$(sbindir)
 	cp -a salinfo-cron-daily.d-salinfo_decode $(prefix)$(crondir)/salinfo_decode
 	cp -a salinfo-etc-init.d-salinfo_decode $(prefix)$(initdir)/salinfo_decode
Index: salinfo-0.5/fpu.h
=================================--- salinfo-0.5.orig/fpu.h	Sun Nov 16 18:34:25 2003
+++ salinfo-0.5/fpu.h	Thu Jan  1 10:00:00 1970
@@ -1,18 +0,0 @@
-#ifndef _ASM_IA64_FPU_H
-#define _ASM_IA64_FPU_H
-
-/*
- * Copyright (C) 1998, 1999, 2002, 2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- * 2003-11-16 Strip down to the bare minimum required to decode SAL records.
- *	      Keith Owens <kaos@sgi.com>
- */
-
-struct ia64_fpreg {
-	union {
-		unsigned long bits[2];
-		long double __dummy;	/* force 16-byte alignment */
-	} u;
-};
-
-#endif /* _ASM_IA64_FPU_H */
Index: salinfo-0.5/sal.h
=================================--- salinfo-0.5.orig/sal.h	Sun Nov 16 18:33:28 2003
+++ salinfo-0.5/sal.h	Wed Sep 15 16:21:10 2004
@@ -25,7 +25,6 @@
  *	      Keith Owens <kaos@sgi.com>
  */
 
-#include "fpu.h"
 #include "efi.h"
 #include "pal.h"
 
Index: salinfo-0.5/salinfo_decode.c
=================================--- salinfo-0.5.orig/salinfo_decode.c	Fri Mar  5 06:36:23 2004
+++ salinfo-0.5/salinfo_decode.c	Wed Sep 15 16:21:10 2004
@@ -155,7 +155,6 @@ fork_oemdata(void)
 		close(pc[1]);
 		oemdata_fd[0] = pc[0];	/* mca.c read from pgm */
 		oemdata_fd[1] = pp[1];	/* mca.c write to pgm */
-		printf("oemdata_fd[0](%d) oemdata_fd[1](%d)\n", oemdata_fd[0], oemdata_fd[1]);
 		__asm__ __volatile__ ("" ::: "memory");	/* lock free barrier */
 		if (child_died)
 			oemdata_fd[1] = -1;

