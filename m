From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 06 Jan 2006 20:24:25 +0000
Subject: Re: [ANNOUNCE] numactl 0.9 released
Message-Id: <Pine.LNX.4.62.0601061222390.18493@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601032257.53039.ak@suse.de>
In-Reply-To: <200601032257.53039.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch in order to make numactl support page migration.

Comments welcome.

Index: numactl-0.9/mbind.2
=================================--- numactl-0.9.orig/mbind.2	2004-06-06 07:12:13.000000000 -0700
+++ numactl-0.9/mbind.2	2006-01-06 10:17:49.000000000 -0800
@@ -67,6 +67,30 @@ parameter 
 will be returned when the existing pages in the mapping don't follow
 the policy.
 
+When
+.B MPOL_MF_MOVE
+is passed in the 
+.B flags
+then attempts will be made to move all the pages in the mapping
+so that they follow the policy. Pages that are shared with other
+processes are not moved. If
+.B MPOL_MF_STRICT
+is also specified then
+.I EIO
+will be returned if some pages could not be moved.
+
+When
+.B MPOL_MF_MOVE_ALL
+is passed in the 
+.B flags
+then all pages in the mapping will be moved regardless of whether
+other processes use the pages. The process specifying this flag must
+have administrative priviledges. If
+.B MPOL_MF_STRICT
+is also specified then
+.I EIO
+will be returned if some pages could not be moved.
+
 The 
 .I MPOL_DEFAULT
 policy is the default and means to use the underlying process policy
@@ -133,6 +157,9 @@ header.
 is ignored on huge page mappings right now. For preferred and interleave 
 mappings it will only accept the first choice node.
 
+.I MPOL_MF_MOVE_*
+is only available on Linux 2.6.16 and later.
+
 For 
 .I MPOL_INTERLEAVE
 mode the interleaving is changed at fault time. The final layout of 
Index: numactl-0.9/numaif.h
=================================--- numactl-0.9.orig/numaif.h	2005-02-11 02:26:47.000000000 -0800
+++ numactl-0.9/numaif.h	2006-01-06 10:59:12.000000000 -0800
@@ -15,6 +15,8 @@ extern long mbind(void *start, unsigned 
 		  const unsigned long *nmask, unsigned long maxnode, unsigned flags);
 extern long set_mempolicy(int mode, const unsigned long *nmask, 
 			  unsigned long maxnode);
+extern long migratepages(int pid, unsigned long maxnode, unsigned long *fromnode,
+			unsigned long *tonode);
 
 /* Policies */
 #define MPOL_DEFAULT     0
@@ -30,6 +32,8 @@ extern long set_mempolicy(int mode, cons
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT  (1<<0)  /* Verify existing pages in the mapping */
+#define MPOL_MF_MOVE	(1<<1)  /* Move pages owned by this process to conform to mapping */
+#define MPOL_MF_MOVE_ALL (1<<2) /* Move every page to conform to mapping */
 
 #ifdef __cplusplus
 }
Index: numactl-0.9/Makefile
=================================--- numactl-0.9.orig/Makefile	2006-01-03 12:36:13.000000000 -0800
+++ numactl-0.9/Makefile	2006-01-06 12:12:14.000000000 -0800
@@ -25,12 +25,14 @@ prefix := /usr
 libdir := ${prefix}$(shell if [ -d /usr/lib64 ] ; then echo "/lib64" ; else echo "/lib"  ; fi)
 docdir := ${prefix}/share/doc
 
-all: numactl libnuma.so numademo numamon memhog test/tshared stream \
+all: numactl migratepages libnuma.so numademo numamon memhog test/tshared stream \
      test/mynode test/pagesize test/ftok test/prefered test/randmap \
 	 test/nodemap test/distance
 
 numactl: numactl.o util.o shm.o bitops.o libnuma.so
 
+migratepages: migratepages.c util.o bitops.o libnuma.so
+
 util.o: util.c
 
 memhog: util.o memhog.o libnuma.so
@@ -94,10 +96,11 @@ set_membind set_preferred set_strict set
 tonodemask_memory distance
 
 MANPAGES := numa.3 numactl.8 mbind.2 set_mempolicy.2 get_mempolicy.2 \
-	    numastat.8
+	    numastat.8 migratepages.8
 
-install: numactl numademo.c numamon memhog libnuma.so.1 numa.h numaif.h numastat ${MANPAGES}
+install: numactl migratepages numademo.c numamon memhog libnuma.so.1 numa.h numaif.h numastat ${MANPAGES}
 	cp numactl ${prefix}/bin
+	cp migratepages ${prefix}/bin
 	cp numademo ${prefix}/bin
 	cp memhog ${prefix}/bin
 	cp set_mempolicy.2 ${prefix}/share/man/man2
Index: numactl-0.9/migratepages.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ numactl-0.9/migratepages.c	2006-01-06 12:20:11.000000000 -0800
@@ -0,0 +1,97 @@
+/*
+ * Copyright (C) 2005 Christoph Lameter, Silicon Graphics, Incorporated.
+ * based on Andi Kleen's numactl.c.
+ *
+ * Manual process migration
+ *
+ * migratepages is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; version 2.
+ *
+ * migratepages is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should find a copy of v2 of the GNU General Public License somewhere
+ * on your Linux system; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#define _GNU_SOURCE
+#include <getopt.h>
+#include <errno.h>
+#include <stdio.h> 
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdarg.h>
+#include "numaif.h"
+#include "numa.h"
+#include "numaint.h"
+#include "util.h"
+
+struct option opts[] = {
+	{"help", 0, 0, 'h' },
+	{ 0 }
+};
+
+void usage(void)
+{
+	fprintf(stderr,
+		"usage: migratepages pid from-nodes to-nodes\n"
+		"\n"
+		"nodes is a comma delimited list of node numbers or A-B ranges or none/all.\n"
+);
+	exit(1);
+}
+
+void checknuma(void)
+{
+	static int numa = -1;
+	if (numa < 0) {
+		if (numa_available() < 0)
+			complain("This system does not support NUMA functionality");
+	}
+	numa = 0;
+}
+
+int main(int argc, char *argv[])
+{
+	int c;
+	char *end;
+	int rc;
+	int pid;
+	nodemask_t fromnodes;
+	nodemask_t tonodes;
+
+	while ((c = getopt_long(argc,argv,"h", opts, NULL)) != -1) {
+		switch (c) {
+		default:
+			usage();
+		}
+	}
+
+	argv += optind;
+	argc -= optind;
+
+	if (argc != 4)
+		usage();
+
+	checknuma();
+
+	pid = strtoul(argv[1], &end, 0);
+	if (*end)
+		usage();
+
+	fromnodes = nodemask(argv[2]);
+	tonodes = nodemask(argv[3]);
+
+	rc = numa_migrate_pages(pid, &fromnodes, &tonodes);
+
+	if (rc) {
+		perror("migrate_pages");
+		return 1;
+	}
+	return 0;
+}
Index: numactl-0.9/syscall.c
=================================--- numactl-0.9.orig/syscall.c	2006-01-03 10:49:17.000000000 -0800
+++ numactl-0.9/syscall.c	2006-01-06 11:55:36.000000000 -0800
@@ -35,10 +35,12 @@
 #define __NR_mbind 237
 #define __NR_set_mempolicy 238
 #define __NR_get_mempolicy 239
+#define __NR_migrate_pages 256
 
 #elif defined(__ia64__)
 #define __NR_sched_setaffinity    1231
 #define __NR_sched_getaffinity    1232
+#define __NR_migrate_pages	1280
 
 /* Official allocation */
 
@@ -51,12 +53,14 @@
 #define __NR_mbind 274
 #define __NR_get_mempolicy 275
 #define __NR_set_mempolicy 276
+#define __NR_migrate_pages 294
 
 #elif defined(__powerpc__)
 
 #define __NR_mbind 259
 #define __NR_get_mempolicy 260
 #define __NR_set_mempolicy 261
+#define __NR_migrate_pages 280
 
 #elif !defined(DEPS_RUN)
 #error "Add syscalls for your architecture or update kernel headers"
@@ -141,6 +145,12 @@ long WEAK set_mempolicy(int mode, const 
 	return syscall(__NR_set_mempolicy,mode,nmask,maxnode);
 }
 
+long WEAK migrate_pages(int pid, unsigned long maxnode,
+	const unsigned long *frommask, const unsigned long *tomask)
+{
+	return syscall(__NR_migrate_pages, pid, maxnode, frommask, tomask);
+}
+
 /* SLES8 glibc doesn't define those */
 
 int numa_sched_setaffinity(pid_t pid, unsigned len, const unsigned long *mask)
@@ -159,3 +169,5 @@ make_internal_alias(numa_sched_setaffini
 make_internal_alias(get_mempolicy);
 make_internal_alias(set_mempolicy);
 make_internal_alias(mbind);
+make_internal_alias(migrate_pages);
+
Index: numactl-0.9/numa.h
=================================--- numactl-0.9.orig/numa.h	2005-12-25 14:20:34.000000000 -0800
+++ numactl-0.9/numa.h	2006-01-06 11:40:25.000000000 -0800
@@ -176,6 +176,8 @@ extern int numa_exit_on_error;
    once. */
 void numa_warn(int num, char *fmt, ...);
 
+int numa_migrate_pages(int pid, const nodemask_t *from, const nodemask_t *to);
+
 #ifdef __cplusplus
 }
 #endif
Index: numactl-0.9/libnuma.c
=================================--- numactl-0.9.orig/libnuma.c	2005-12-19 04:11:51.000000000 -0800
+++ numactl-0.9/libnuma.c	2006-01-06 12:00:03.000000000 -0800
@@ -600,6 +600,19 @@ nodemask_t numa_get_run_node_mask(void)
 	return mask;
 } 
 
+int numa_migrate_pages(int pid, const nodemask_t *fromnodes, const nodemask_t *tonodes)
+{
+	int err;
+
+	err = migrate_pages(pid, NUMA_NUM_NODES + 1, &fromnodes->n[0], &tonodes->n[0]);
+
+	if (err < 0) {
+		errno = -err;
+		return -1;
+	}
+	return err;
+}
+
 int numa_run_on_node(int node)
 { 
 	int ncpus = number_of_cpus();
Index: numactl-0.9/numaint.h
=================================--- numactl-0.9.orig/numaint.h	2005-04-28 04:40:38.000000000 -0700
+++ numactl-0.9/numaint.h	2006-01-06 11:56:36.000000000 -0800
@@ -11,7 +11,9 @@ extern long mbind_int(void *start, unsig
 		  const unsigned long *nmask, unsigned long maxnode, unsigned flags);
 extern long set_mempolicy_int(int mode, const unsigned long *nmask, 
 			  unsigned long maxnode);
-                                                    
+extern long migrate_pages(int pid, unsigned long maxnode, const unsigned long *frommask,
+	const unsigned long *tomask);
+
 #define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
 
 #define CPU_BYTES(x) (round_up(x, BITS_PER_LONG)/8)
Index: numactl-0.9/migratepages.8
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ numactl-0.9/migratepages.8	2006-01-06 12:18:03.000000000 -0800
@@ -0,0 +1,63 @@
+.\" t
+.\" Copyright 2005 Christoph Lameter, Silicon Graphics, Inc.
+.\"
+.\" based on Andi Kleen's numactl manpage
+.\"
+.TH MIGRATEPAGES 8 "Jan 2005" "SGI" "Linux Administrator's Manual"
+.SH NAME
+migratepages \- Migrate the physical location of pages of a process
+.SH SYNOPSIS
+.B migratepages
+pid from-nodes to-nodes
+.SH DESCRIPTION
+.B migratepages
+moves the physical localtion of a processes pages without any changes of the
+virtual address space of the process. This is usually done to optimize
+the performance of a process by moving the pages near to the processor
+executing a process.
+.TP
+Valid node specifiers
+.TS
+tab(:);
+l l. 
+all:All nodes
+number:Node number
+number1{,number2}:Node number1 and Node number2
+number1-number2:Nodes from number1 to number2
+! nodes:Invert selection of the following specification.
+.TE
+.SH NOTES
+Requires an NUMA policy aware kernel.
+
+migratepages will only move pages that are not shared with other
+processes if called by a user without administrative priviledges (but
+with the right to modify the process).
+
+migratepages will move all pages if invoked from root (or a user with
+administrative priviledges).
+
+.SH FILES
+.I /proc/<pid>/numastat
+for information about the NUMA memory use of a process.
+.SH COPYRIGHT
+Copyright 2005 Christoph Lameter, Silicon Graphics, Inc.
+migratepages is under the GNU General Public License, v.2
+
+.SH SEE ALSO
+.I numactl(8)
+,
+.I set_mempolicy(2)
+,
+.I get_mempolicy(2)
+,
+.I mbind(2)
+,
+.I sched_setaffinity(2)
+, 
+.I sched_getaffinity(2)
+,
+.I proc(5)
+, 
+.I ftok(3)
+,
+.I shmat(2)
Index: numactl-0.9/numactl.8
=================================--- numactl-0.9.orig/numactl.8	2005-12-16 04:13:19.000000000 -0800
+++ numactl-0.9/numactl.8	2006-01-06 12:11:31.000000000 -0800
@@ -271,3 +271,6 @@ numactl and the demo programs are under 
 .I ftok(3)
 ,
 .I shmat(2)
+,
+.I migratepages(8)
+
