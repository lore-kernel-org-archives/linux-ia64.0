From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 03 Jun 2004 20:28:35 +0000
Subject: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized ITC
Message-Id: <Pine.LNX.4.58.0406031313420.32412@server.home>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The current code in sysdeps/ia64/hp-timing.h expects the ITC to deliver an
monotonic increasing clock value. That is assured only on UP systems and
on SMP systems with synchronized ITC clocks.

Some systems (like the SGI Altix) do not have synchronized ITC clocks. If
a process is moved to another processor and ITC is used to determine time
then time may seem to be running backwards or leaping because ITC values
from different CPUs are compared.

IA64 kernels provide a proc file /proc/sal/itc_drift that contains "1" if
the platform has an unsynchronized ITC.

The following patch checks for drifty ITC clocks based on that file. If
ITC is drifty then it generates timestamps based on the gettimeofday
system call.

This also contains a small fix for elf/rtld-Rules

Index: glibc-2.3.2-200309260658/elf/rtld-Rules
=================================--- glibc-2.3.2-200309260658.orig/elf/rtld-Rules	2003-07-24 20:31:13.000000000 -0700
+++ glibc-2.3.2-200309260658/elf/rtld-Rules	2004-05-28 12:43:27.000000000 -0700
@@ -31,7 +31,7 @@
 ifeq ($(subdir),elf)

 ifndef rtld-subdirs
-error This makefile is a subroutine of elf/Makefile not to be used directly
+$(error This makefile is a subroutine of elf/Makefile not to be used directly)
 endif

 include ../Makeconfig
Index: glibc-2.3.2-200309260658/sysdeps/ia64/Makefile
=================================--- glibc-2.3.2-200309260658.orig/sysdeps/ia64/Makefile	2004-05-25 18:02:27.000000000 -0700
+++ glibc-2.3.2-200309260658/sysdeps/ia64/Makefile	2004-06-01 19:09:43.000000000 -0700
@@ -12,7 +12,7 @@

 ifeq (yes,$(build-shared))
 # Compatibility
-sysdep_routines += libgcc-compat
+sysdep_routines += libgcc-compat
 shared-only-routines += libgcc-compat
 endif
 endif
@@ -21,4 +21,15 @@
 sysdep-dl-routines += dl-symaddr dl-fptr
 sysdep_routines += $(sysdep-dl-routines)
 sysdep-rtld-routines += $(sysdep-dl-routines)
+sysdep-dl-routines += hp-timing
 endif
+
+ifeq ($(subdir),posix)
+sysdep_routines += hp-timing
+endif
+
+ifeq ($(subdir),malloc)
+libmemusage-routines += hp-timing
+endif
+
+
Index: glibc-2.3.2-200309260658/sysdeps/ia64/hp-timing.c
=================================--- glibc-2.3.2-200309260658.orig/sysdeps/ia64/hp-timing.c	2004-05-27 16:57:50.000000000 -0700
+++ glibc-2.3.2-200309260658/sysdeps/ia64/hp-timing.c	2004-06-01 10:08:00.000000000 -0700
@@ -18,7 +18,54 @@
    Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA.  */

+#include <errno.h>
+#include <time.h>
+#include <unistd.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/time.h>
+#include <fcntl.h>
+
 #include <hp-timing.h>

 /* We have to define the variable for the overhead.  */
 hp_timing_t _dl_hp_timing_overhead;
+/* Values
+   itc_drifting =-1 using ITC
+   itc_drifitng =1 using CLOCK_REALTIME
+   itc_drifting =0 itc_drifting not yet determined
+*/
+int itc_drifting=0;
+
+unsigned long int hp_gettimestamp(void)
+{
+	if (itc_drifting>0)
+get_realtimestamp:
+	{
+		struct timeval t;
+		// clock_gettime is not working in the elf loader... use gettimeofday
+		__gettimeofday(&t,NULL);
+		return t.tv_usec+t.tv_sec*1000000UL;
+	}
+	else
+	{
+		int fd = open ("/proc/sal/itc_drift", O_RDONLY);
+		unsigned long x;
+
+		itc_drifting=-1;
+		if (__builtin_expect (fd != -1, 1))
+		{
+			char buf[16];
+			/* We expect the file to contain a single digit followed by
+			   a newline.  If the format changes we better not rely on
+			   the file content.  */
+			if (read (fd, buf, sizeof buf) != 2 || buf[0] != '0' || buf[1] != '\n')
+				itc_drifting=1;
+			close (fd);
+		}
+		if (itc_drifting>=0) goto get_realtimestamp;
+		HP_TIMING_NOW(x);
+		return x;
+	}
+}
+
Index: glibc-2.3.2-200309260658/sysdeps/ia64/hp-timing.h
=================================--- glibc-2.3.2-200309260658.orig/sysdeps/ia64/hp-timing.h	2004-05-27 16:57:50.000000000 -0700
+++ glibc-2.3.2-200309260658/sysdeps/ia64/hp-timing.h	2004-06-01 12:00:26.000000000 -0700
@@ -72,11 +72,13 @@
 /* We always assume having the timestamp register.  */
 #define HP_TIMING_AVAIL		(1)

-/* We indeed have inlined functions.  */
-#define HP_TIMING_INLINE	(1)
+/* We indeed have inlined functions but sometimes we need to make a call.  */
+#define HP_TIMING_INLINE	(0)

 /* We use 64bit values for the times.  */
 typedef unsigned long int hp_timing_t;
+int itc_drifting;
+unsigned long hp_gettimestamp(void);

 /* Set timestamp value to zero.  */
 #define HP_TIMING_ZERO(Var)	(Var) = (0)
@@ -91,10 +93,13 @@
 /* That's quite simple.  Use the `ar.itc' instruction.  */
 #define HP_TIMING_NOW(Var) \
   ({ unsigned long int __itc;						      \
+    if (itc_drifting>=0) Var=hp_gettimestamp();				\
+    else {								\
      do									      \
        asm volatile ("mov %0=ar.itc" : "=r" (__itc) : : "memory");	      \
-     while (REPEAT_READ (__itc));					      \
-     Var = __itc; })
+      while (REPEAT_READ (__itc));					      \
+      Var = __itc; }							\
+   })

 /* Use two 'ar.itc' instructions in a row to find out how long it takes.  */
 #define HP_TIMING_DIFF_INIT() \
