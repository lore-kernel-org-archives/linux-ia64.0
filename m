From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 19:53:06 +0000
Subject: [PATCH] kill kdba_io.c
Message-Id: <marc-linux-ia64-106451999732542@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith shared my opionion that it's completly useless.  Also everyone
seems to favour keeping kdb stuff out of mainline.


--- 1.4/arch/ia64/sn/io/sn2/Makefile	Thu Jul  3 21:55:24 2003
+++ edited/arch/ia64/sn/io/sn2/Makefile	Sun Aug 10 02:02:16 2003
@@ -14,6 +14,3 @@
 obj-y += pcibr/ ml_SN_intr.o shub_intr.o shuberror.o shub.o bte_error.o \
 	 pic.o geo_op.o l1_command.o klconflib.o klgraph.o ml_SN_init.o \
 	 ml_iograph.o module.o pciio.o xbow.o xtalk.o shubio.o
-
-obj-$(CONFIG_KDB) += kdba_io.o 
-obj-$(CONFIG_SHUB_1_0_SPECIFIC) += efi-rtc.o
--- 1.1/arch/ia64/sn/io/sn2/kdba_io.c	Fri May 16 20:50:50 2003
+++ edited/arch/ia64/sn/io/sn2/kdba_io.c	Sun Aug 10 01:48:57 2003
@@ -1,76 +0,0 @@
-/*
- * Kernel Debugger Architecture Dependent POD functions.
- *
- * Copyright (C) 1999-2003 Silicon Graphics, Inc.  All Rights Reserved
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it would be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
- *
- * Further, this software is distributed without any warranty that it is
- * free of the rightful claim of any third person regarding infringement
- * or the like.  Any license provided herein, whether implied or
- * otherwise, applies only to this software file.  Patent licenses, if
- * any, provided herein do not apply to combinations of this program with
- * other software, or any other product whatsoever.
- *
- * You should have received a copy of the GNU General Public
- * License along with this program; if not, write the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- *
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
- * Mountain View, CA  94043, or:
- *
- * http://www.sgi.com
- *
- * For further information regarding this notice, see:
- *
- * http://oss.sgi.com/projects/GenInfo/NoticeExplan
- */
-
-#include <linux/types.h>
-#include <linux/kdb.h>
-//#include <linux/kdbprivate.h>
-
-/**
- * kdba_io - enter POD mode from kdb
- * @argc: arg count
- * @argv: arg values
- * @envp: kdb env. vars
- * @regs: current register state
- *
- * Enter POD mode from kdb using SGI SN specific SAL function call.
- */
-static int
-kdba_io(int argc, const char **argv, const char **envp, struct pt_regs *regs)
-{
-	kdb_printf("kdba_io entered with addr 0x%p\n", (void *) regs);
-
-        return(0);
-}
-
-/**
- * kdba_io_init - register 'io' command with kdb
- *
- * Register the 'io' command with kdb at load time.
- */
-void
-kdba_io_init(void)
-{
-        kdb_register("io", kdba_io, "<vaddr>", "Display IO Contents", 0);
-}
-
-/**
- * kdba_io_exit - unregister the 'io' command
- *
- * Tell kdb that the 'io' command is no longer available.
- */
-static void __exit
-kdba_exit(void)
-{
-        kdb_unregister("io");
-}
