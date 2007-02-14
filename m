From: William Cohen <wcohen@redhat.com>
Date: Wed, 14 Feb 2007 17:05:31 +0000
Subject: Re: [perfmon] 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <45D3415B.7080104@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040005070204050008020103"
List-Id: <linux-ia64.vger.kernel.org>
References: <20070213184839.GC10031@frankl.hpl.hp.com> <45D23042.1020802@redhat.com>
In-Reply-To: <45D23042.1020802@redhat.com>
To: William Cohen <wcohen@redhat.com>
Cc: eranian@hpl.hp.com, perfmon@napali.hpl.hp.com, oprofile-list@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------040005070204050008020103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

William Cohen wrote:
> Hello Stephane,
> 
> The oprofile patch should be made against the oprofile cvs rather than 
> the 0.9.2 tarball. There are some files that the patch touches that are 
> created by the autogen.sh.
> 
> The oprofile patch doesn't build if things are configured without the 
> "--enable-perfmon2".
> 
> gcc -W -Wall -fno-common -Wdeclaration-after-statement 
> -fno-omit-frame-pointer -g -O2   -o oprofiled  init.o oprofiled.o 
> opd_stats.o opd_sfile.o opd_kernel.o opd_trans.o opd_cookie.o 
> opd_events.o opd_mangling.o opd_perfmon.o opd_perfmon_22.o 
> opd_perfmon_compat.o opd_anon.o liblegacy/liblegacy.a ../libabi/libabi.a 
> ../libdb/libodb.a ../libop/libop.a ../libutil/libutil.a -lpopt -liberty 
> -ldl
> opd_perfmon.o: In function `perfmon_init':
> /home/wcohen/research/profiling/oprofile/oprofile-0.9.2-perfmon2/daemon/opd_perfmon.c:384: 
> undefined reference to `do_perfmon_init'
> collect2: ld returned 1 exit status
> 
> -Will

Hi Stephane,

I tweaked the oprofile patch a bit so that it applies to the oprofile cvs 
repository and builds with and without being configured with --enable-perfmon2. 
The patch is attached.

Things that will need to be done to the patch:

-handle case where perfmon pmd/pmc registers are unavailable
	Is the method being used going to work for systemwide perfmon?
		create a thread local context then collect unavail regs.
	What happens if another thread using a register that is marked
		available in the current thread?
-handle naming differences between oprofile events and perfmon2
-general cleanup

-Will

--------------040005070204050008020103
Content-Type: text/x-patch;
 name="oprof-perfmon2-cvs4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oprof-perfmon2-cvs4.diff"

--- oprofile-perfmon2/utils/opcontrol.orig	2007-02-05 13:34:09.000000000 -0500
+++ oprofile-perfmon2/utils/opcontrol	2007-02-14 10:43:52.000000000 -0500
@@ -298,6 +298,14 @@
 	do_init_daemon_vars
 	decide_oprofile_device
 
+	OP_IMPLEMENTATION_DIR=$MOUNT/implementation
+	if test -f $OP_IMPLEMENTATION; then
+	    OP_IMPLEMENTATION=`cat $OP_IMPLEMENTATION_DIR`
+	else
+	    OP_IMPLEMENTATION="unspecified"
+	fi
+
+
 	DEFAULT_EVENT=`$OPHELP --get-default-event`
  
 	IS_TIMER=0
@@ -305,10 +313,19 @@
 	if test "$CPUTYPE" = "timer"; then
 		IS_TIMER=1
 	else
-		case "$CPUTYPE" in
+	    case $OP_IMPLEMENTATION in
+		perfmon2)
+		    IS_PERFMON=$KERNEL_SUPPORT
+		    ;;
+		unspecified)
+		    case "$CPUTYPE" in
 			ia64/*)
 				IS_PERFMON=$KERNEL_SUPPORT
 				;;
+		    esac
+		    ;;
+		*)
+			;;
 		esac
 	fi
 
--- /dev/null	2007-02-14 09:26:07.827526703 -0500
+++ oprofile-perfmon2/daemon/opd_perfmon_compat.c	2007-02-14 10:43:32.000000000 -0500
@@ -0,0 +1,152 @@
+/**
+ * @file opd_perfmon_ia64.c
+ * perfmonctl() handling for perfmon v2.0 on IA-64 only
+ * perfmon v2.2 or higher is handled by opd_perfmon.c even for IA-64
+ *
+ * @remark Copyright 2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon
+ */
+
+#if defined(__ia64__)
+
+/* need this for sched_setaffinity() in <sched.h> */
+#define _GNU_SOURCE
+
+#include "oprofiled.h"
+#include "opd_perfmon.h"
+#include "opd_events.h"
+
+#include "op_cpu_type.h"
+#include "op_libiberty.h"
+#include "op_hw_config.h"
+
+#include <sys/syscall.h>
+#include <sys/wait.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+#ifdef OPROF_PERFMON2
+#include <perfmon/perfmon.h>
+#include <perfmon/pfmlib.h>
+#include <perfmon/perfmon_default_smpl.h>
+static pfm_uuid_t uuid = PFM_DEFAULT_SMPL_UUID;
+#else
+#ifndef HAVE_PERFMONCTL
+#ifndef __NR_perfmonctl
+#define __NR_perfmonctl 1175
+#endif
+
+static int perfmonctl(int fd, int cmd, void * arg, int narg)
+{
+	return syscall(__NR_perfmonctl, fd, cmd, arg, narg);
+}
+#endif
+
+static unsigned char uuid[16] = {
+	0x77, 0x7a, 0x6e, 0x61, 0x20, 0x65, 0x73, 0x69,
+	0x74, 0x6e, 0x72, 0x20, 0x61, 0x65, 0x0a, 0x6c
+};
+#endif
+
+
+int do_create_context_compat(void)
+{
+	pfarg_context_t ctx;
+	int err;
+
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.ctx_flags = PFM_FL_SYSTEM_WIDE;
+	memcpy(ctx.ctx_smpl_buf_id, uuid, sizeof(uuid));
+
+	err = perfmonctl(0, PFM_CREATE_CONTEXT, &ctx, 1);
+	if (err == -1)
+		return -1;
+
+	return ctx.ctx_fd;
+}
+
+/*
+ * Mapping OProfile -> Perfmon2
+ * 0  -> PMC4, PMD4
+ * 1  -> PMC5, PMD5
+ * 2  -> PMC6, PMD6
+ * 3  -> PMC7, PMD7
+ */
+int do_write_pmu_compat(int fd)
+{
+	int err;
+	size_t i;
+	pfarg_reg_t pc[OP_MAX_COUNTERS];
+	pfarg_reg_t pd[OP_MAX_COUNTERS];
+
+	memset(pc, 0, sizeof(pc));
+	memset(pd, 0, sizeof(pd));
+
+#define PMC_PRIV_MONITOR (1UL << 6)
+#define PMC_USER (1UL << 3)
+#define PMC_KERNEL (1UL << 0)
+
+	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
+		struct opd_event * event = &opd_events[i];
+
+		pc[i].reg_num = event->counter + 4;
+
+		pc[i].reg_value = PMC_PRIV_MONITOR;
+		(event->user) ? (pc[i].reg_value |= PMC_USER)
+		              : (pc[i].reg_value &= ~PMC_USER);
+		(event->kernel) ? (pc[i].reg_value |= PMC_KERNEL)
+		                : (pc[i].reg_value &= ~PMC_KERNEL);
+		pc[i].reg_value &= ~(0xfful << 8);
+		pc[i].reg_value |= ((event->value & 0xfful) << 8);
+		pc[i].reg_value &= ~(0xful << 16);
+		pc[i].reg_value |= ((event->um & 0xful) << 16);
+		pc[i].reg_smpl_eventid = event->counter;
+
+		pd[i].reg_num = event->counter + 4;
+		pd[i].reg_value = -event->count;
+		pd[i].reg_short_reset = -event->count;
+		pd[i].reg_smpl_eventid = event->counter;
+	}
+
+	err = perfmonctl(fd, PFM_WRITE_PMCS, pc, op_nr_counters);
+	if (err == -1)
+		return -1;
+
+	err = perfmonctl(fd, PFM_WRITE_PMDS, pd, op_nr_counters);
+	if (err == -1)
+		return -1;
+
+	return 0;
+}
+
+int do_load_context_compat(int fd, pid_t pid, size_t cpu)
+{
+	pfarg_load_t load_args;
+
+	memset(&load_args, 0, sizeof(load_args));
+
+	load_args.load_pid = pid;
+
+	return perfmonctl(fd, PFM_LOAD_CONTEXT, &load_args, 1);
+}
+
+int do_start_child_compat(int ctx_fd)
+{
+	return perfmonctl(ctx_fd, PFM_START, NULL, 0);
+}
+
+int do_stop_child_compat(int ctx_fd)
+{
+	return perfmonctl(ctx_fd, PFM_STOP, NULL, 0);
+}
+
+void do_perfmon_init_compat(void)
+{
+}
+
+#endif /* defined(__ia64__) */
--- oprofile-perfmon2/daemon/opd_perfmon.c.orig	2004-12-12 18:26:35.000000000 -0500
+++ oprofile-perfmon2/daemon/opd_perfmon.c	2007-02-14 11:37:11.000000000 -0500
@@ -8,8 +8,6 @@
  * @author John Levon
  */
 
-#ifdef __ia64__
-
 /* need this for sched_setaffinity() in <sched.h> */
 #define _GNU_SOURCE
 
@@ -34,6 +32,31 @@
 #include <sched.h>
 #endif
 
+#if !defined( __ia64__) && ! defined(OPROF_PERFMON2)
+void perfmon_init(void) {}
+void perfmon_exit(void) {}
+void perfmon_start(void) {}
+void perfmon_stop(void) {}
+#else
+
+/* FIXME fatal_error is just temporary */
+static void fatal_error(char *fmt,...) __attribute__((noreturn));
+
+static int pfm_version, use_compat;
+#define PFM_VERSION_22 (2<<16|2)
+
+static void
+fatal_error(char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+
+	exit(EXIT_FAILURE);
+}
+
 extern op_cpu cpu_type;
 
 #ifndef HAVE_SCHED_SETAFFINITY
@@ -63,25 +86,6 @@
 }
 #endif
 
-
-#ifndef HAVE_PERFMONCTL
-#ifndef __NR_perfmonctl
-#define __NR_perfmonctl 1175
-#endif
-
-static int perfmonctl(int fd, int cmd, void * arg, int narg)
-{
-	return syscall(__NR_perfmonctl, fd, cmd, arg, narg);
-}
-#endif
-
-
-static unsigned char uuid[16] = {
-	0x77, 0x7a, 0x6e, 0x61, 0x20, 0x65, 0x73, 0x69,
-	0x74, 0x6e, 0x72, 0x20, 0x61, 0x65, 0x0a, 0x6c
-};
-
-
 static size_t nr_cpus;
 
 struct child {
@@ -97,21 +101,29 @@
 
 static void perfmon_start_child(int ctx_fd)
 {
-	if (perfmonctl(ctx_fd, PFM_START, 0, 0) == -1) {
-		perror("Couldn't start perfmon: ");
-		exit(EXIT_FAILURE);
-	}
-}
+	int ret;
+
+	if (use_compat)
+		ret = do_start_child_compat(ctx_fd);
+	else
+		ret = do_start_child(ctx_fd);
 
+	if (ret == -1)
+		fatal_error("Couldn't start perfmon: %s\n", strerror(errno));
+}
 
 static void perfmon_stop_child(int ctx_fd)
 {
-	if (perfmonctl(ctx_fd, PFM_STOP, 0, 0) == -1) {
-		perror("Couldn't stop perfmon: ");
-		exit(EXIT_FAILURE);
-	}
-}
+	int ret;
+
+	if (use_compat)
+		ret = do_stop_child_compat(ctx_fd);
+	else
+		ret = do_stop_child(ctx_fd);
 
+	if (ret == -1)
+		fatal_error("Couldn't stop perfmon: %s\n", strerror(errno));
+}
 
 static void child_sigusr1(int val __attribute__((unused)))
 {
@@ -149,17 +161,16 @@
 static void set_affinity(size_t cpu)
 {
 	cpu_set_t set;
+	int err;
 
 	CPU_ZERO(&set);
 	CPU_SET(cpu, &set);
 
-	int err = sched_setaffinity(getpid(), sizeof(set), &set);
+	err = sched_setaffinity(getpid(), sizeof(set), &set);
 
-	if (err == -1) {
-		fprintf(stderr, "Failed to set affinity: %s\n",
+	if (err == -1)
+		fatal_error("Failed to set affinity: %s\n",
 			    strerror(errno));
-		exit(EXIT_FAILURE);
-	}
 }
 
 
@@ -177,125 +188,72 @@
 	act.sa_flags = 0;
 	sigemptyset(&act.sa_mask);
 
-	if (sigaction(SIGUSR1, &act, NULL)) {
-		perror("oprofiled: install of SIGUSR1 handler failed: ");
-		exit(EXIT_FAILURE);
-	}
+	if (sigaction(SIGUSR1, &act, NULL))
+		fatal_error("oprofiled: install of SIGUSR1 handler failed: %s\n",
+			strerror(errno));
 
 	act.sa_handler = child_sigusr2;
 	act.sa_flags = 0;
 	sigemptyset(&act.sa_mask);
 
-	if (sigaction(SIGUSR2, &act, NULL)) {
-		perror("oprofiled: install of SIGUSR2 handler failed: ");
-		exit(EXIT_FAILURE);
-	}
+	if (sigaction(SIGUSR2, &act, NULL))
+		fatal_error("oprofiled: install of SIGUSR2 handler failed: %s\n",
+			strerror(errno));
 
 	act.sa_handler = child_sigterm;
 	act.sa_flags = 0;
 	sigemptyset(&act.sa_mask);
 
-	if (sigaction(SIGTERM, &act, NULL)) {
-		perror("oprofiled: install of SIGTERM handler failed: ");
-		exit(EXIT_FAILURE);
-	}
+	if (sigaction(SIGTERM, &act, NULL))
+		fatal_error("oprofiled: install of SIGTERM handler failed: %s\n",
+			strerror(errno));
 }
 
-
 /** create the per-cpu context */
 static void create_context(struct child * self)
 {
-	pfarg_context_t ctx;
-	int err;
+	int ret;
 
-	memset(&ctx, 0, sizeof(pfarg_context_t));
-	memcpy(&ctx.ctx_smpl_buf_id, &uuid, 16);
-	ctx.ctx_flags = PFM_FL_SYSTEM_WIDE;
-
-	err = perfmonctl(0, PFM_CREATE_CONTEXT, &ctx, 1);
-	if (err == -1) {
-		fprintf(stderr, "CREATE_CONTEXT failed: %s\n",
-		        strerror(errno));
-		exit(EXIT_FAILURE);
-	}
+	if (use_compat)
+		ret = do_create_context_compat();
+	else
+		ret = do_create_context();
+	if (ret == -1)
+		fatal_error("create context failed: %s\n",
+	        	strerror(errno));
 
-	self->ctx_fd = ctx.ctx_fd;
+	self->ctx_fd = ret;
 }
 
-
 /** program the perfmon counters */
 static void write_pmu(struct child * self)
 {
-	pfarg_reg_t pc[OP_MAX_COUNTERS];
-	pfarg_reg_t pd[OP_MAX_COUNTERS];
-	int err;
-	size_t i;
-
-	memset(pc, 0, sizeof(pc));
-	memset(pd, 0, sizeof(pd));
+	int ret;
+	
+	if (use_compat)
+		ret = do_write_pmu_compat(self->ctx_fd);
+	else
+		ret = do_write_pmu(self->ctx_fd);
+
+	if (ret == -1)
+		fatal_error("create write PMU: %s\n",
+	        	strerror(errno));
 
-#define PMC_GEN_INTERRUPT (1UL << 5)
-#define PMC_PRIV_MONITOR (1UL << 6)
-/* McKinley requires pmc4 to have bit 23 set (enable PMU).
- * It is supposedly ignored in other pmc registers.
- */
-#define PMC_MANDATORY (1UL << 23)
-#define PMC_USER (1UL << 3)
-#define PMC_KERNEL (1UL << 0)
-	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
-		struct opd_event * event = &opd_events[i];
-		pc[i].reg_num = event->counter + 4;
-		pc[i].reg_value = PMC_GEN_INTERRUPT;
-		pc[i].reg_value |= PMC_PRIV_MONITOR;
-		pc[i].reg_value |= PMC_MANDATORY;
-		(event->user) ? (pc[i].reg_value |= PMC_USER)
-		              : (pc[i].reg_value &= ~PMC_USER);
-		(event->kernel) ? (pc[i].reg_value |= PMC_KERNEL)
-		                : (pc[i].reg_value &= ~PMC_KERNEL);
-		pc[i].reg_value &= ~(0xff << 8);
-		pc[i].reg_value |= ((event->value & 0xff) << 8);
-		pc[i].reg_value &= ~(0xf << 16);
-		pc[i].reg_value |= ((event->um & 0xf) << 16);
-		pc[i].reg_smpl_eventid = event->counter;
-	}
-
-	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
-		struct opd_event * event = &opd_events[i];
-		pd[i].reg_value = ~0UL - event->count + 1;
-		pd[i].reg_short_reset = ~0UL - event->count + 1;
-		pd[i].reg_num = event->counter + 4;
-	}
-
-	err = perfmonctl(self->ctx_fd, PFM_WRITE_PMCS, pc, i);
-	if (err == -1) {
-		perror("Couldn't write PMCs: ");
-		exit(EXIT_FAILURE);
-	}
-
-	err = perfmonctl(self->ctx_fd, PFM_WRITE_PMDS, pd, i);
-	if (err == -1) {
-		perror("Couldn't write PMDs: ");
-		exit(EXIT_FAILURE);
-	}
 }
 
+static void load_context(struct child * self, size_t cpu)
+{
+	int ret;
+	
+	if (use_compat)
+		ret = do_load_context_compat(self->ctx_fd, self->pid, cpu);
+	else
+		ret = do_load_context(self->ctx_fd, self->pid, cpu);
 
-static void load_context(struct child * self)
-{
-	pfarg_load_t load_args;
-	int err;
-
-	memset(&load_args, 0, sizeof(load_args));
-	load_args.load_pid = self->pid;
-
-	err = perfmonctl(self->ctx_fd, PFM_LOAD_CONTEXT, &load_args, 1);
-	if (err == -1) {
-		perror("Couldn't load context: ");
-		exit(EXIT_FAILURE);
-	}
+	if (ret == -1)
+		fatal_error("Couldn't load context: %s\n", strerror(errno));
 }
 
-
 static void notify_parent(struct child * self, size_t cpu)
 {
 	for (;;) {
@@ -303,15 +261,12 @@
 		ret = write(self->up_pipe[1], &cpu, sizeof(size_t));
 		if (ret == sizeof(size_t))
 			break;
-		if (ret < 0 && errno != EINTR) {
-			fprintf(stderr, "Failed to write child pipe with %s\n",
-			        strerror(errno));
-			exit(EXIT_FAILURE);
-		}
+		if (ret < 0 && errno != EINTR)
+			fatal_error("Failed to write child pipe with %s\n",
+				strerror(errno));
 	}
 }
 
-
 static void run_child(size_t cpu)
 {
 	struct child * self = &children[cpu];
@@ -329,7 +284,7 @@
 
 	write_pmu(self);
 
-	load_context(self);
+	load_context(self, cpu);
 
 	notify_parent(self, cpu);
 
@@ -367,11 +322,9 @@
 		ret = read(child->up_pipe[0], &tmp, sizeof(size_t));
 		if (ret == sizeof(size_t))
 			break;
-		if (ret < 0 && errno != EINTR) {
-			fprintf(stderr, "Failed to read child pipe with %s\n",
+		if (ret < 0 && errno != EINTR)
+			fatal_error("Failed to read child pipe with %s\n",
 			        strerror(errno));
-			exit(EXIT_FAILURE);
-		}
 	}
 	printf("Perfmon child up on CPU%d\n", (int)tmp);
 	fflush(stdout);
@@ -380,6 +333,44 @@
 	close(child->up_pipe[1]);
 }
 
+static void perfmon_get_version(void)
+{
+	FILE *fp;
+	char *buf = NULL;
+	size_t len = 0;
+	char *p;
+	int ret;
+
+	fp = fopen("/sys/kernel/perfmon/version", "r");
+	if (fp == NULL)
+		fatal_error("host kernel does not have perfmon support\n");
+
+	ret = getline(&buf, &len, fp);
+	if (ret < 0)
+		fatal_error("cannot extract perfmon version\n");
+
+	p = strchr(buf, '.');
+	if (p == NULL)
+		goto invalid_format;
+
+	*p = '\0';
+	pfm_version = atoi(buf) << 16;
+	p++;
+	pfm_version |= atoi(p);
+
+	free(buf);
+	fclose(fp);
+
+	/*
+	 * check if using v2.0 (IA-64 only)
+	 */
+	if (pfm_version <= PFM_VERSION_22)
+		use_compat = 1;
+	return;
+
+invalid_format:
+	fatal_error("cannot parse perfmon version number\n");
+}
 
 void perfmon_init(void)
 {
@@ -390,10 +381,14 @@
 		return;
 
 	nr = sysconf(_SC_NPROCESSORS_ONLN);
-	if (nr == -1) {
-		fprintf(stderr, "Couldn't determine number of CPUs.\n");
-		exit(EXIT_FAILURE);
-	}
+	if (nr == -1)
+		fatal_error("Couldn't determine number of CPUs.\n");
+
+	perfmon_get_version();
+	if (use_compat)
+		do_perfmon_init_compat();
+	else
+		do_perfmon_init();
 
 	nr_cpus = nr;
 
@@ -402,16 +397,14 @@
 	for (i = 0; i < nr_cpus; ++i) {
 		int ret;
 
-		if (pipe(children[i].up_pipe)) {
-			perror("Couldn't create child pipe.\n");
-			exit(EXIT_FAILURE);
-		}
+		if (pipe(children[i].up_pipe))
+			fatal_error("Couldn't create child pipe: %s\n", strerror(errno));
 
 		ret = fork();
-		if (ret == -1) {
-			fprintf(stderr, "Couldn't fork perfmon child.\n");
-			exit(EXIT_FAILURE);
-		} else if (ret == 0) {
+		if (ret == -1)
+			fatal_error("Couldn't fork perfmon child.\n");
+
+		if (ret == 0) {
 			printf("Running perfmon child on CPU%d.\n", (int)i);
 			fflush(stdout);
 			run_child(i);
@@ -461,4 +454,4 @@
 		kill(children[i].pid, SIGUSR2);
 }
 
-#endif /* __ia64__ */
+#endif
--- oprofile-perfmon2/daemon/Makefile.am.orig	2005-08-04 14:27:26.000000000 -0400
+++ oprofile-perfmon2/daemon/Makefile.am	2007-02-14 11:30:16.000000000 -0500
@@ -20,12 +20,14 @@
 	opd_interface.h \
 	opd_mangling.c \
 	opd_mangling.h \
+	opd_anon.h \
+	opd_anon.c \
 	opd_perfmon.h \
 	opd_perfmon.c \
-	opd_anon.h \
-	opd_anon.c
+	opd_perfmon_22.c \
+	opd_perfmon_compat.c
 
-LIBS=@POPT_LIBS@ @LIBERTY_LIBS@
+LIBS=@POPT_LIBS@ @LIBERTY_LIBS@ @PFM_LIBS@
 
 AM_CPPFLAGS = \
 	-I ${top_srcdir}/libabi \
--- oprofile-perfmon2/daemon/opd_perfmon.h.orig	2003-10-22 06:51:37.000000000 -0400
+++ oprofile-perfmon2/daemon/opd_perfmon.h	2007-02-14 11:34:46.000000000 -0500
@@ -11,8 +11,6 @@
 #ifndef OPD_PERFMON_H
 #define OPD_PERFMON_H
 
-#ifdef __ia64__
-
 #include <stdlib.h>
 
 void perfmon_init(void);
@@ -20,6 +18,15 @@
 void perfmon_start(void);
 void perfmon_stop(void);
 
+#ifdef __ia64__
+extern void do_perfmon_init_compat(void);
+extern int  do_start_child_compat(int fd);
+extern int  do_stop_child_compat(int fd);
+extern int  do_create_context_compat(void);
+extern int  do_write_pmu_compat(int fd);
+extern int  do_load_context_compat(int fd, pid_t pid, size_t cpu);
+
+#ifndef OPROF_PERFMON2
 /* The following is from asm/perfmon.h. When it's installed on
  * enough boxes, we can remove this and include the platform
  * perfmon.h
@@ -79,28 +86,32 @@
 #define PFM_CREATE_CONTEXT  0x08
 #define PFM_LOAD_CONTEXT    0x10
 #define PFM_FL_SYSTEM_WIDE  0x02
+#endif
 
 #else
 
-void perfmon_init(void)
-{
-}
-
-
-void perfmon_exit(void)
-{
-}
-
-
-void perfmon_start(void)
-{
-}
-
-
-void perfmon_stop(void)
-{
-}
-
-#endif /* __ia64__ */
+#define do_perfmon_init_compat()
+#define do_start_child_compat(fd) (-1)
+#define do_stop_child_compat(fd) (-1)
+#define do_create_context_compat() (-1)
+#define do_write_pmu_compat(fd) (-1)
+#define do_load_context_compat(fd, pid, cpu) (-1)
+#endif
+
+#ifdef OPROF_PERFMON2
+extern void do_perfmon_init(void);
+extern int do_start_child(int fd);
+extern int do_stop_child(int fd);
+extern int do_create_context(void);
+extern int do_write_pmu(int fd);
+extern int do_load_context(int fd, pid_t pid, size_t cpu);
+#else
+#define do_perfmon_init_compat()
+#define do_start_child(fd) (-1)
+#define do_stop_child(fd) (-1)
+#define do_create_context() (-1)
+#define do_write_pmu(fd) (-1)
+#define do_load_context(fd, pid, cpu) (-1)
+#endif /* OPROF_PERFMON2 */
 
 #endif /* OPD_PERFMON_H */
--- /dev/null	2007-02-14 09:26:07.827526703 -0500
+++ oprofile-perfmon2/daemon/opd_perfmon_22.c	2007-02-14 11:49:32.000000000 -0500
@@ -0,0 +1,687 @@
+/**
+ * @file opd_perfmon.c
+ * perfmonctl() handling
+ *
+ * @remark Copyright 2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon
+ */
+
+#ifdef OPROF_PERFMON2
+/* need this for sched_setaffinity() in <sched.h> */
+#define _GNU_SOURCE
+
+#include "oprofiled.h"
+#include "opd_perfmon.h"
+#include "opd_events.h"
+
+#include "op_cpu_type.h"
+#include "op_libiberty.h"
+#include "op_hw_config.h"
+
+#include <sys/syscall.h>
+#include <sys/wait.h>
+#include <unistd.h>
+#include <limits.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <perfmon/perfmon.h>
+#include <perfmon/pfmlib.h>
+
+extern op_cpu cpu_type;
+
+typedef struct {
+	pfarg_pmc_t pc[OP_MAX_COUNTERS];
+	pfarg_pmd_t pd[OP_MAX_COUNTERS];
+	uint64_t *avail_pmcs;
+	unsigned int n_pmcs, n_pmds;
+
+} pmu_reg_desc_t;
+
+static int (*write_pmu)(pmu_reg_desc_t *desc);
+
+static int pmc_is_avail(uint64_t *avail, unsigned int i)
+{
+	return avail[i>>6] & (1ULL << (i&63));
+}
+
+#if 0
+/* FIXME this should be used to determine which counters cannot be used */
+/*
+ * Mapping between OProfile and perfmon2:
+ * 	for P6, Opteron, PII, Core Duo: identity
+ */
+static int get_unavail_counters_p6(u32 *avail_mask)
+{
+	pfarg_ctx_t ctx;
+	pfarg_setinfo_t	setf;
+	int nr = -1, i, fd;
+
+	memset(&ctx, 0, sizeof(ctx));
+	memset(&setf, 0, sizeof(setf));
+
+	fd = pfm_create_context(&ctx, NULL, NULL, 0);
+	if (fd == -1)
+		return -1;
+
+	/*
+	 * extract list of available PMC/PMD
+	 */
+	nr = pfm_getinfo_evtsets(fd, &setf, 1);
+	if (nr == -1)
+		goto error;
+
+	/*
+	 * populate OProfile avail counter mask
+	 *
+	 * all PMD are counters, identity mapping
+	 */
+	nr = 0;
+	for(i=0; i < 32; i++) {
+		if (setf.set_avail_pmds[0] & (1ULL<<i)) {
+			*avail_mask |= 1 <<i;
+			nr++;
+		}
+	}
+error:
+	close(fd);
+	return nr;
+}
+#endif
+
+/*
+ * Mapping between OProfile and perfmon2:
+ * 	for P6, Opteron, PII, Core Duo: identity
+ */
+static int write_pmu_p6(pmu_reg_desc_t *desc)
+{
+	unsigned int i;
+
+	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
+		struct opd_event * event = &opd_events[i];
+
+		/*
+		 * XXX: needs to take into account unavailable PMCs
+		 */
+		desc->pc[i].reg_num   = event->counter;
+		desc->pc[i].reg_value = (uint64_t)event->value;
+		desc->pc[i].reg_value |= (uint64_t)event->um << 8;
+
+		/* set enable bit */
+		desc->pc[i].reg_value |= 1ULL << 22;
+
+		if (event->kernel)
+			desc->pc[i].reg_value |= 1ULL << 17;
+		if (event->user)
+			desc->pc[i].reg_value |= 1ULL << 16;
+
+		desc->pd[i].reg_num   = event->counter;
+		desc->pd[i].reg_value       = - (uint64_t)event->count;
+		desc->pd[i].reg_short_reset = - (uint64_t)event->count;
+		desc->pd[i].reg_long_reset  = - (uint64_t)event->count;
+		desc->pd[i].reg_smpl_eventid = event->counter;
+	}
+	if (opd_events[i].name)
+		return -1;
+	desc->n_pmcs = desc->n_pmds = i;
+	return 0;
+}
+
+/*
+ * Mapping between OProfile and perfmon2:
+ * 	for Core 2 Duo: generic counters starts at PMC4, need to setup global control
+ */
+static int write_pmu_core2(pmu_reg_desc_t *desc)
+{
+	uint64_t enable_mask = 0;
+	unsigned int  i;
+
+	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
+		struct opd_event * event = &opd_events[i];
+
+		/*
+		 * XXX: needs to take into account unavailable PMCs
+		 */
+		desc->pc[i].reg_num   = 4 + event->counter;
+		desc->pc[i].reg_value = (uint64_t)event->value;
+		desc->pc[i].reg_value |= (uint64_t)event->um << 8;
+
+		/* set enable bit */
+		desc->pc[i].reg_value |= 1ULL << 22;
+
+		enable_mask |= 1ULL << (desc->pc[i].reg_num - 4);
+
+		if (event->kernel)
+			desc->pc[i].reg_value |= 1ULL << 17;
+
+		if (event->user)
+			desc->pc[i].reg_value |= 1ULL << 16;
+
+		desc->pd[i].reg_num   = 4 + event->counter;
+		desc->pd[i].reg_value       = - (uint64_t)event->count;
+		desc->pd[i].reg_short_reset = - (uint64_t)event->count;
+		desc->pd[i].reg_long_reset  = - (uint64_t)event->count;
+		desc->pd[i].reg_smpl_eventid = event->counter;
+	}
+	if (opd_events[i].name)
+		return -1;
+
+	desc->n_pmds = i;
+
+	if (pmc_is_avail(desc->avail_pmcs, 0)) {
+		desc->pc[i].reg_num = 0;
+		desc->pc[i].reg_value = enable_mask;
+		i++;
+	}
+	desc->n_pmcs = i;
+	return 0;
+}
+
+/*
+ * Mapping between OProfile and perfmon2:
+ * 	for all IA-64 processors: identity
+ */
+static int write_pmu_ia64(pmu_reg_desc_t *desc)
+{
+	unsigned int i;
+
+	for (i = 0; i < op_nr_counters && opd_events[i].name; ++i) {
+		struct opd_event * event = &opd_events[i];
+
+		/*
+		 * XXX: needs to take into account unavailable PMCs
+		 */
+		desc->pc[i].reg_num   = event->counter;
+		desc->pc[i].reg_value = (uint64_t)event->value;
+
+		/* model-specific field, same position so far */
+		desc->pc[i].reg_value |= (uint64_t)event->um << 16;
+
+		if (event->kernel)
+			desc->pc[i].reg_value |= 1ULL;
+		if (event->user)
+			desc->pc[i].reg_value |= 1ULL << 3;
+
+		desc->pd[i].reg_num   = event->counter;
+		desc->pd[i].reg_value       = - (uint64_t)event->count;
+		desc->pd[i].reg_short_reset = - (uint64_t)event->count;
+		desc->pd[i].reg_long_reset  = - (uint64_t)event->count;
+		desc->pd[i].reg_smpl_eventid = event->counter;
+	}
+	if (opd_events[i].name)
+		return -1;
+	desc->n_pmcs = desc->n_pmds = i;
+	return 0;
+}
+
+struct p4_counter_binding {
+	int virt_counter;
+	unsigned long counter_address;
+	unsigned long cccr_address;
+};
+
+#define CTR_BPU_0      (1 << 0)
+#define CTR_MS_0       (1 << 1)
+#define CTR_FLAME_0    (1 << 2)
+#define CTR_IQ_4       (1 << 3)
+#define CTR_BPU_2      (1 << 4)
+#define CTR_MS_2       (1 << 5)
+#define CTR_FLAME_2    (1 << 6)
+#define CTR_IQ_5       (1 << 7)
+
+#define PFM_BPU_ESCR0 0
+#define PFM_IS_ESCR0 1
+#define PFM_MOB_ESCR0 2
+#define PFM_ITLB_ESCR0 3
+#define PFM_PMH_ESCR0 4
+#define PFM_IX_ESCR0 5
+#define PFM_FSB_ESCR0 6
+#define PFM_BSU_ESCR0 7
+#define PFM_MS_ESCR0 8
+#define PFM_TC_ESCR0 9
+#define PFM_TBPU_ESCR0 10
+#define PFM_FLAME_ESCR0 11
+#define PFM_FIRM_ESCR0 12
+#define PFM_SAAT_ESCR0 13
+#define PFM_U2L_ESCR0 14
+#define PFM_DAC_ESCR0 15
+#define PFM_ALF_ESCR0 17
+#define PFM_RAT_ESCR0 18
+#define PFM_SSU_ESCR0 19
+#define PFM_CRU_ESCR0 20
+#define PFM_CRU_ESCR2 21
+#define PFM_CRU_ESCR4 22
+#define PFM_BPU_CCCR0 23
+#define PFM_BPU_CCCR1 24
+#define PFM_MS_CCCR0 25
+#define PFM_MS_CCCR1 26
+#define PFM_FLAME_CCCR0 27
+#define PFM_FLAME_CCCR1 28
+#define PFM_IQ_CCCR0 29
+#define PFM_IQ_CCCR1 30
+#define PFM_IQ_CCCR4 31
+#define PFM_BPU_ESCR1 32
+#define PFM_IS_ESCR1 33
+#define PFM_MOB_ESCR1 34
+#define PFM_ITLB_ESCR1 35
+#define PFM_PMH_ESCR1 36
+#define PFM_IX_ESCR1 37
+#define PFM_FSB_ESCR1 38
+#define PFM_BSU_ESCR1 39
+#define PFM_MS_ESCR1 40
+#define PFM_TC_ESCR1 41
+#define PFM_TBPU_ESCR1 42
+#define PFM_FLAME_ESCR1 43
+#define PFM_FIRM_ESCR1 44
+#define PFM_SAAT_ESCR1 45
+#define PFM_U2L_ESCR1 46
+#define PFM_DAC_ESCR1 47
+#define PFM_ALF_ESCR1 49
+#define PFM_RAT_ESCR1 50
+#define PFM_CRU_ESCR1 51
+#define PFM_CRU_ESCR3 52
+#define PFM_CRU_ESCR5 53
+#define PFM_BPU_CCCR2 54
+#define PFM_BPU_CCCR3 55
+#define PFM_MS_CCCR2 56
+#define PFM_MS_CCCR3 57
+#define PFM_FLAME_CCCR2 58
+#define PFM_FLAME_CCCR3 59
+#define PFM_IQ_CCCR2 60
+#define PFM_IQ_CCCR3 61
+#define PFM_IQ_CCCR5 62
+#define PFM_PEBS_MATRIX_VERT 63
+#define PFM_PEBS_ENABLE 64
+#define PFM_BPU_CTR0 0
+#define PFM_BPU_CTR1 1
+#define PFM_MS_CTR0 2
+#define PFM_MS_CTR1 3
+#define PFM_FLAME_CTR0 4
+#define PFM_FLAME_CTR1 5
+#define PFM_IQ_CTR0 6
+#define PFM_IQ_CTR1 7
+#define PFM_IQ_CTR4 8
+#define PFM_BPU_CTR2 9
+#define PFM_BPU_CTR3 10
+#define PFM_MS_CTR2 11
+#define PFM_MS_CTR3 12
+#define PFM_FLAME_CTR2 13
+#define PFM_FLAME_CTR3 14
+#define PFM_IQ_CTR2 15
+#define PFM_IQ_CTR3 16
+#define PFM_IQ_CTR5 17
+
+static struct p4_counter_binding p4_counters [] = {
+	{ CTR_BPU_0,   PFM_BPU_CTR0,   PFM_BPU_CCCR0 },
+	{ CTR_MS_0,    PFM_MS_CTR0,    PFM_MS_CCCR0 },
+	{ CTR_FLAME_0, PFM_FLAME_CTR0, PFM_FLAME_CCCR0 },
+	{ CTR_IQ_4,    PFM_IQ_CTR4,    PFM_IQ_CCCR4 },
+	{ CTR_BPU_2,   PFM_BPU_CTR2,   PFM_BPU_CCCR2 },
+	{ CTR_MS_2,    PFM_MS_CTR2,    PFM_MS_CCCR2 },
+	{ CTR_FLAME_2, PFM_FLAME_CTR2, PFM_FLAME_CCCR2 },
+	{ CTR_IQ_5,    PFM_IQ_CTR5,    PFM_IQ_CCCR5 }
+};
+
+struct p4_event_binding {
+	int escr_select;  /* value to put in CCCR */
+	int event_select; /* value to put in ESCR */
+	struct {
+		int virt_counter; /* for this counter... */
+		int escr_address; /* use this ESCR       */
+	} bindings[2];
+};
+
+
+static struct p4_event_binding p4_events[] = {
+	{ /* BRANCH_RETIRED */
+		0x05, 0x06, 
+		{ {CTR_IQ_4, PFM_CRU_ESCR2},
+		  {CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* MISPRED_BRANCH_RETIRED */
+		0x04, 0x03, 
+		{ { CTR_IQ_4, PFM_CRU_ESCR0},
+		  { CTR_IQ_5, PFM_CRU_ESCR1} }
+	},
+	{ /* TC_DELIVER_MODE */
+		0x01, 0x01,
+		{ { CTR_MS_0, PFM_TC_ESCR0},  
+		  { CTR_MS_2, PFM_TC_ESCR1} }
+	},
+	{ /* BPU_FETCH_REQUEST */
+		0x00, 0x03, 
+		{ { CTR_BPU_0, PFM_BPU_ESCR0},
+		  { CTR_BPU_2, PFM_BPU_ESCR1} }
+	},
+	{ /* ITLB_REFERENCE */
+		0x03, 0x18,
+		{ { CTR_BPU_0, PFM_ITLB_ESCR0},
+		  { CTR_BPU_2, PFM_ITLB_ESCR1} }
+	},
+	{ /* MEMORY_CANCEL */
+		0x05, 0x02,
+		{ { CTR_FLAME_0, PFM_DAC_ESCR0},
+		  { CTR_FLAME_2, PFM_DAC_ESCR1} }
+	},
+	{ /* MEMORY_COMPLETE */
+		0x02, 0x08,
+		{ { CTR_FLAME_0, PFM_SAAT_ESCR0},
+		  { CTR_FLAME_2, PFM_SAAT_ESCR1} }
+	},
+	{ /* LOAD_PORT_REPLAY */
+		0x02, 0x04, 
+		{ { CTR_FLAME_0, PFM_SAAT_ESCR0},
+		  { CTR_FLAME_2, PFM_SAAT_ESCR1} }
+	},
+	{ /* STORE_PORT_REPLAY */
+		0x02, 0x05,
+		{ { CTR_FLAME_0, PFM_SAAT_ESCR0},
+		  { CTR_FLAME_2, PFM_SAAT_ESCR1} }
+	},
+	{ /* MOB_LOAD_REPLAY */
+		0x02, 0x03,
+		{ { CTR_BPU_0, PFM_MOB_ESCR0},
+		  { CTR_BPU_2, PFM_MOB_ESCR1} }
+	},
+	{ /* PAGE_WALK_TYPE */
+		0x04, 0x01,
+		{ { CTR_BPU_0, PFM_PMH_ESCR0},
+		  { CTR_BPU_2, PFM_PMH_ESCR1} }
+	},
+	{ /* BSQ_CACHE_REFERENCE */
+		0x07, 0x0c, 
+		{ { CTR_BPU_0, PFM_BSU_ESCR0},
+		  { CTR_BPU_2, PFM_BSU_ESCR1} }
+	},
+	{ /* IOQ_ALLOCATION */
+		0x06, 0x03, 
+		{ { CTR_BPU_0, PFM_FSB_ESCR0},
+		  { 0, 0 } }
+	},
+	{ /* IOQ_ACTIVE_ENTRIES */
+		0x06, 0x1a, 
+		{ { CTR_BPU_2, PFM_FSB_ESCR1},
+		  { 0, 0 } }
+	},
+	{ /* FSB_DATA_ACTIVITY */
+		0x06, 0x17, 
+		{ { CTR_BPU_0, PFM_FSB_ESCR0},
+		  { CTR_BPU_2, PFM_FSB_ESCR1} }
+	},
+	{ /* BSQ_ALLOCATION */
+		0x07, 0x05, 
+		{ { CTR_BPU_0, PFM_BSU_ESCR0},
+		  { 0, 0 } }
+	},
+	{ /* BSQ_ACTIVE_ENTRIES */
+		0x07, 0x06,
+		{ { CTR_BPU_2, PFM_BSU_ESCR1 /* guess */},  
+		  { 0, 0 } }
+	},
+	{ /* X87_ASSIST */
+		0x05, 0x03, 
+		{ { CTR_IQ_4, PFM_CRU_ESCR2},
+		  { CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* SSE_INPUT_ASSIST */
+		0x01, 0x34,
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* PACKED_SP_UOP */
+		0x01, 0x08, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* PACKED_DP_UOP */
+		0x01, 0x0c, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* SCALAR_SP_UOP */
+		0x01, 0x0a, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* SCALAR_DP_UOP */
+		0x01, 0x0e,
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* 64BIT_MMX_UOP */
+		0x01, 0x02, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* 128BIT_MMX_UOP */
+		0x01, 0x1a, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* X87_FP_UOP */
+		0x01, 0x04, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* X87_SIMD_MOVES_UOP */
+		0x01, 0x2e, 
+		{ { CTR_FLAME_0, PFM_FIRM_ESCR0},
+		  { CTR_FLAME_2, PFM_FIRM_ESCR1} }
+	},
+	{ /* MACHINE_CLEAR */
+		0x05, 0x02, 
+		{ { CTR_IQ_4, PFM_CRU_ESCR2},
+		  { CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* GLOBAL_POWER_EVENTS */
+		0x06, 0x13 /* older manual says 0x05, newer 0x13 */,
+		{ { CTR_BPU_0, PFM_FSB_ESCR0},
+		  { CTR_BPU_2, PFM_FSB_ESCR1} }
+	},
+	{ /* TC_MS_XFER */
+		0x00, 0x05, 
+		{ { CTR_MS_0, PFM_MS_ESCR0},
+		  { CTR_MS_2, PFM_MS_ESCR1} }
+	},
+	{ /* UOP_QUEUE_WRITES */
+		0x00, 0x09,
+		{ { CTR_MS_0, PFM_MS_ESCR0},
+		  { CTR_MS_2, PFM_MS_ESCR1} }
+	},
+	{ /* FRONT_END_EVENT */
+		0x05, 0x08,
+		{ { CTR_IQ_4, PFM_CRU_ESCR2},
+		  { CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* EXECUTION_EVENT */
+		0x05, 0x0c,
+		{ { CTR_IQ_4, PFM_CRU_ESCR2},
+		  { CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* REPLAY_EVENT */
+		0x05, 0x09,
+		{ { CTR_IQ_4, PFM_CRU_ESCR2},
+		  { CTR_IQ_5, PFM_CRU_ESCR3} }
+	},
+	{ /* INSTR_RETIRED */
+		0x04, 0x02, 
+		{ { CTR_IQ_4, PFM_CRU_ESCR0},
+		  { CTR_IQ_5, PFM_CRU_ESCR1} }
+	},
+	{ /* UOPS_RETIRED */
+		0x04, 0x01,
+		{ { CTR_IQ_4, PFM_CRU_ESCR0},
+		  { CTR_IQ_5, PFM_CRU_ESCR1} }
+	},
+	{ /* UOP_TYPE */    
+		0x02, 0x02, 
+		{ { CTR_IQ_4, PFM_RAT_ESCR0},
+		  { CTR_IQ_5, PFM_RAT_ESCR1} }
+	},
+	{ /* RETIRED_MISPRED_BRANCH_TYPE */
+		0x02, 0x05, 
+		{ { CTR_MS_0, PFM_TBPU_ESCR0},
+		  { CTR_MS_2, PFM_TBPU_ESCR1} }
+	},
+	{ /* RETIRED_BRANCH_TYPE */
+		0x02, 0x04,
+		{ { CTR_MS_0, PFM_TBPU_ESCR0},
+		  { CTR_MS_2, PFM_TBPU_ESCR1} }
+	}
+};
+
+static int write_pmu_p4(pmu_reg_desc_t *desc)
+{
+	unsigned int i, j;
+	unsigned long escr, cccr, ctr;
+	uint64_t value;
+
+	for (j = 0, i = 0; j< op_nr_counters && opd_events[j].name; ++j, i++) {
+		struct opd_event * event = &opd_events[j];
+
+		printf("counter=%ld um=0x%lx value=0x%lx\n", event->counter, event->um, event->value);
+
+		ctr  = p4_events[event->value -1].bindings[0].virt_counter;
+		escr = p4_events[event->value -1].bindings[0].escr_address;
+		cccr = p4_counters[ctr - 1].cccr_address;
+		ctr  = p4_counters[ctr - 1].counter_address;
+
+		printf("escr_sel=0x%x evnt_sel=0x%x\n", p4_events[event->value - 1].escr_select, p4_events[event->value - 1].event_select);
+		printf("ctr=0x%lx escr=0x%lx cccr=0x%lx\n", ctr, escr, cccr);
+
+
+		value  = p4_events[event->value -1].event_select << 25;
+		value |= event->um << 9;
+		if (event->kernel)
+			value |= 1ULL << 3;
+		if (event->user)
+			value |= 1ULL << 2;
+
+		desc->pc[i].reg_num   = escr;
+		desc->pc[i].reg_value = value;
+		i++;
+
+		value  = p4_events[event->value -1].escr_select << 13;
+		value |= 1ULL << 12; /* enable bit */
+		/*
+		 * XXX: needs to take into account unavailable PMCs
+		 */
+		desc->pc[i].reg_num   = cccr;
+		desc->pc[i].reg_value = value;
+
+		desc->pd[j].reg_num   = ctr;
+		desc->pd[j].reg_value       = - (uint64_t)event->count;
+		desc->pd[j].reg_short_reset = - (uint64_t)event->count;
+		desc->pd[j].reg_long_reset  = - (uint64_t)event->count;
+		desc->pd[j].reg_smpl_eventid = event->counter;
+	}
+
+	if (opd_events[j].name)
+		return -1;
+
+	desc->n_pmcs = i;
+	desc->n_pmds = j;
+
+	return 0;
+}
+
+int do_start_child(int ctx_fd)
+{
+	return pfm_start(ctx_fd, NULL);
+}
+
+int do_stop_child(int ctx_fd)
+{
+	return pfm_stop(ctx_fd);
+}
+
+int do_create_context(void)
+{
+	pfarg_ctx_t ctx;
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.ctx_flags = PFM_FL_SYSTEM_WIDE;
+
+	return pfm_create_context(&ctx, "OProfile", NULL, 0);
+}
+
+int do_write_pmu(int fd)
+{
+	pmu_reg_desc_t desc;
+	pfarg_setinfo_t	setf;
+	int err;
+
+	memset(&desc, 0, sizeof(desc));
+	memset(&setf, 0, sizeof(setf));
+
+	/*
+	 * extract list of available PMC
+	 */
+	err = pfm_getinfo_evtsets(fd, &setf, 1);
+	if (err == -1)
+		return -1;
+
+	desc.avail_pmcs = setf.set_avail_pmcs;
+
+	/*
+	 * assign OProfile counters to Perfmon PMC/PMD
+	 */
+	err = write_pmu(&desc);
+	if (err == -1)
+		return -1;
+
+	/*
+	 * write PMC registers
+	 */
+	err = pfm_write_pmcs(fd, desc.pc, desc.n_pmcs);
+	if (err == -1)
+		return -1;
+
+	/*
+	 * write PMD registers
+	 */
+	err = pfm_write_pmds(fd, desc.pd, desc.n_pmds);
+	if (err == -1)
+		return -1;
+	return 0;
+}
+
+int do_load_context(int fd, pid_t pid  __attribute__((unused)), size_t cpu)
+{
+	pfarg_load_t load_args;
+
+	memset(&load_args, 0, sizeof(load_args));
+
+	load_args.load_pid = cpu;
+
+	return pfm_load_context(fd, &load_args);
+}
+
+void do_perfmon_init(void)
+{
+	switch(cpu_type) {
+		case CPU_HAMMER:
+		case CPU_P6_MOBILE:
+		case CPU_CORE:
+		case CPU_PPRO ... CPU_ATHLON:
+			write_pmu = write_pmu_p6;
+			break;
+		case CPU_CORE_2:
+			write_pmu = write_pmu_core2;
+			break;
+		case CPU_P4:
+		case CPU_P4_HT2:
+			write_pmu = write_pmu_p4;
+			break;
+		case CPU_IA64 ... CPU_IA64_2:
+			write_pmu = write_pmu_ia64;
+			break;
+		default:
+			return;
+	}
+}
+
+#endif /* OPROF_PERFMON2 */
--- oprofile-perfmon2/configure.in.orig	2006-09-15 18:43:24.000000000 -0400
+++ oprofile-perfmon2/configure.in	2007-02-14 10:43:29.000000000 -0500
@@ -133,6 +133,18 @@
 AC_SUBST(BFD_LIBS)
 AC_SUBST(POPT_LIBS)
 
+dnl enable option to use perfmon use on processors other than ia64
+AC_ARG_ENABLE(perfmon2,
+	[  --enable-perfmon2            enable option for perfmon2 use on non-ia64 processors (default is disabled)],
+	enable_perfmon2=$enableval, enable_perfmon2=no)
+if test "$enable_perfmon2" = yes; then
+	AC_CHECK_LIB(pfm, pfm_start,, AC_MSG_ERROR([pfm library not found]))
+	PFM_LIBS="-lpfm"
+	AC_SUBST(PFM_LIBS)
+	AX_CFLAGS_OPTION(OP_CFLAGS,[-DOPROF_PERFMON2])
+	AX_CXXFLAGS_OPTION(OP_CXXFLAGS,[-DOPROF_PERFMON2])
+fi
+
 # do NOT put tests here, they will fail in the case X is not installed !
  
 AM_CONDITIONAL(have_qt, test -n "$QT_LIB")

--------------040005070204050008020103--
