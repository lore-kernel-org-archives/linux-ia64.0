From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 05:10:53 +0000
Subject: [Linux-ia64] sprofil() implementation
Message-Id: <marc-linux-ia64-105590693005308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Attached below is an implementation of the sprofil() call.  My main
motivation for adding this was to be able to support profiling with
32-bit counters (16-bit counters would overflow after just one minute
on IA-64 Linux...), but the routine is designed to also work well with
lots of text sections, so this could provide the foundation for
profiling shared binaries.

Some comments:

	- it hasn't been tested very much so far, though the
	  included test program works as expected and it does
	  attempt to stress some of the more complex aspects
	  of sprofil()

	- the patch for the Makefile isn't quite right; I couldn't
	  figure out what I needed to do to get "make check" to
	  build and run the tst-sprofil program

	- the code has been tested on IA-64 Linux only, though I did
	  try to make it as portable as the profil() implementation

	- when a histogram counter exceeds the maximum value, instead
	  of wrapping around, this implementation of sprofil() leaves
	  the counter at the saturated value; this is different from
	  profil() but I think it's a better behavior and I didn't see
	  it precluded in any of the documentation I had access to

Note that in order to use the 32-bit profiling counters, you'll also
need a gprof patch (and a few more patches to the gmon support).
Unfortunately, those patches are not ready yet...

Enjoy,

	--david

2001-03-20  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/generic/sprofil.c: New file.
	* sysdeps/posix/sprofil.c: Ditto.
	* gmon/tst-sprofil.c: Ditto.
	* gmon/sys/profil.h: Ditto.

diff -urN --exclude CVS libc/gmon/Makefile libc-lia/gmon/Makefile
--- libc/gmon/Makefile	Tue Aug 19 20:29:10 1997
+++ libc-lia/gmon/Makefile	Tue Mar 20 19:16:43 2001
@@ -23,7 +23,7 @@
 
 headers	:= sys/gmon.h sys/gmon_out.h
 distribute := machine-gmon.h profil-counter.h
-routines := gmon mcount profil bb_init_func bb_exit_func prof-freq
+routines := gmon mcount profil sprofil bb_init_func bb_exit_func prof-freq
 
 include ../Rules
 
@@ -35,9 +35,11 @@
 # On systems where `profil' is not a system call, the same
 # problem exists for the internal functions in profil.c.
 
+tests	:= tst-sprofil
+
 noprof := mcount
 ifeq (,$(filter profil,$(unix-syscalls)))
-noprof += profil
+noprof += profil sprofil
 endif
 
 $(noprof:%=$(objpfx)%.op): %.op: %.o
diff -urN --exclude CVS libc/gmon/sys/profil.h libc-lia/gmon/sys/profil.h
--- libc/gmon/sys/profil.h	Wed Dec 31 16:00:00 1969
+++ libc-lia/gmon/sys/profil.h	Tue Mar 20 20:47:04 2001
@@ -0,0 +1,61 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   This file is part of the GNU C Library.
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
+#ifndef _PROFIL_H
+#define _PROFIL_H	1
+
+#include <features.h>
+
+#include <sys/time.h>
+#include <sys/types.h>
+
+__BEGIN_DECLS
+
+/* This interface is intended to follow the sprofil() system calls as
+   described by the sprofil(2) man page of Irix v6.5, except that:
+
+	- there is no a priori limit on number of text sections
+	- pr_scale is declared as unsigned long (instead of "unsigned int")
+	- pr_size is declared as size_t (instead of "unsigned int")
+	- pr_off is declared as void * (instead of "__psunsigned_t")
+	- the overflow bin (pr_base=0, pr_scale=2) can appear anywhere
+	  in the profp array
+	- PROF_FAST has no effect  */
+
+struct prof
+  {
+    void *pr_base;		/* buffer base */
+    size_t pr_size;		/* buffer size */
+    size_t pr_off;		/* pc offset */
+    unsigned long pr_scale;	/* pc scaling (fixed-point number) */
+  };
+
+enum
+  {
+    PROF_USHORT	= 0,		/* use 16-bit counters (default) */
+    PROF_UINT	= (1 << 0),	/* use 32-bit counters */
+    PROF_FAST   = (1 << 1)	/* profile faster than usual */
+  };
+
+extern int sprofil (struct prof *, int, struct timeval *, unsigned int);
+
+__END_DECLS
+
+#endif /* profil.h */
diff -urN --exclude CVS libc/gmon/tst-sprofil.c libc-lia/gmon/tst-sprofil.c
--- libc/gmon/tst-sprofil.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/gmon/tst-sprofil.c	Tue Mar 20 20:19:02 2001
@@ -0,0 +1,165 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
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
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+
+#include <sys/profil.h>
+
+#define NELEMS(a)	(sizeof (a)/sizeof ((a)[0]))
+
+size_t taddr[] +  {
+    0x00001000,		/* elf32/hppa */
+    0x08048000,		/* elf32/x86 */
+    0x00400000,		/* elf32/mips */
+    0x01800000,		/* elf32/ppc */
+    0x00010000,		/* elf32/sparc */
+    0x4000000000000000,	/* elf64/ia64 */
+    0x0000000120000000,	/* elf64/alpha */
+    0x4000000000001000,	/* elf64/hppa */
+    0x0000000100000000	/* elf64/sparc */
+  };
+
+unsigned int buf[NELEMS (taddr)][0x10000/sizeof (int)];
+unsigned int bshort[5][0x100/sizeof (int)];
+unsigned int blong[1][0x1000/sizeof (int)];
+unsigned int vlong[1][0x2000/sizeof (int)];
+
+long
+fac (long n)
+{
+  if (n = 0)
+    return 1;
+  return n*fac (n - 1);
+}
+
+int
+main (int argc, char **argv)
+{
+  unsigned int ovfl = 0, profcnt = 0;
+  struct timeval tv, start;
+  struct prof prof[32];
+  double t_tick, delta;
+  long sum = 0;
+  int i, j;
+
+  for (i = 0; i < NELEMS (taddr); ++i)
+    {
+      prof[profcnt].pr_base = buf[i];
+      prof[profcnt].pr_size = sizeof (buf[i]);
+      prof[profcnt].pr_off = (size_t) taddr[i];
+      prof[profcnt].pr_scale = 0x10000;
+      ++profcnt;
+    }
+
+  prof[profcnt].pr_base = blong[0];
+  prof[profcnt].pr_size = sizeof (blong[0]);
+  prof[profcnt].pr_off = 0x80001000;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = bshort[0];
+  prof[profcnt].pr_size = sizeof (bshort[0]);
+  prof[profcnt].pr_off = 0x80000080;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = bshort[1];
+  prof[profcnt].pr_size = sizeof (bshort[1]);
+  prof[profcnt].pr_off = 0x80000f80;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = bshort[2];
+  prof[profcnt].pr_size = sizeof (bshort[2]);
+  prof[profcnt].pr_off = 0x80001080;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = bshort[3];
+  prof[profcnt].pr_size = sizeof (bshort[3]);
+  prof[profcnt].pr_off = 0x80001f80;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = bshort[4];
+  prof[profcnt].pr_size = sizeof (bshort[4]);
+  prof[profcnt].pr_off = 0x80002080;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  prof[profcnt].pr_base = vlong[0];
+  prof[profcnt].pr_size = sizeof (vlong[0]);
+  prof[profcnt].pr_off = 0x80000080;
+  prof[profcnt].pr_scale = 0x10000;
+  ++profcnt;
+
+  /* Set up overflow counter (must be last on Irix).  */
+  prof[profcnt].pr_base = &ovfl;
+  prof[profcnt].pr_size = sizeof (ovfl);
+  prof[profcnt].pr_off = 0;
+  prof[profcnt].pr_scale = 2;
+  ++profcnt;
+
+  /* Turn it on.  */
+  if (sprofil (prof, profcnt, &tv, PROF_UINT) < 0)
+    {
+      if (errno = ENOSYS)
+	exit (0);
+      perror ("sprofil");
+      exit (1);
+    }
+
+  t_tick = tv.tv_sec + 1e-6*tv.tv_usec;
+  printf ("profiling period = %g ms\n", 1e3*t_tick);
+
+  gettimeofday (&start, NULL);
+  do
+    {
+      for (i = 0; i < 21; ++i)
+	sum += fac (i);
+
+      gettimeofday (&tv, NULL);
+      timersub (&tv, &start, &tv);
+      delta = tv.tv_sec + 1e-6*tv.tv_usec;
+    }
+  while (delta < 1000*t_tick);
+
+  printf ("sum = 0x%lx\n", sum);
+
+  /* Turn it off.  */
+  if (sprofil (NULL, 0, NULL, 0) < 0)
+    {
+      if (errno = ENOSYS)
+	exit (0);
+      perror ("sprofil");
+      exit (1);
+    }
+
+  printf ("overflow = %u\n", ovfl);
+  for (i = 0; i < NELEMS (taddr); ++i)
+    for (j = 0; j < 0x10000/sizeof (int); ++j)
+      if (buf[i][j] != 0)
+	printf ("%Zx\t%u\t(buffer %d)\n",
+		(taddr[i] + (char *) &buf[i][j] - (char *) &buf[i][0]),
+		buf[i][j], i);
+  return 0;
+}
diff -urN --exclude CVS libc/sysdeps/generic/sprofil.c libc-lia/sysdeps/generic/sprofil.c
--- libc/sysdeps/generic/sprofil.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/generic/sprofil.c	Tue Mar 20 20:35:17 2001
@@ -0,0 +1,37 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   This file is part of the GNU C Library.
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
+#include <errno.h>
+
+#include <sys/profil.h>
+#include <sys/time.h>
+
+int
+__sprofil (struct prof *profp, int profcnt, struct timeval *tvp,
+	   unsigned int flags)
+{
+  if (profcnt = 0)
+    return 0;
+
+  __set_errno (ENOSYS);
+  return -1;
+}
+
+weak_alias (__sprofil, sprofil)
diff -urN --exclude CVS libc/sysdeps/posix/sprofil.c libc-lia/sysdeps/posix/sprofil.c
--- libc/sysdeps/posix/sprofil.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/posix/sprofil.c	Tue Mar 20 20:31:58 2001
@@ -0,0 +1,355 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   This file is part of the GNU C Library.
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
+#include <assert.h>
+#include <signal.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+
+#include <sys/time.h>
+#include <sys/profil.h>
+
+#ifndef SIGPROF
+# include <sysdeps/generic/sprofil.c>
+#else
+
+#include <libc-internal.h>
+
+struct region
+  {
+    size_t offset;
+    size_t nsamples;
+    unsigned int scale;
+    union
+      {
+	void *vp;
+	unsigned short *us;
+	unsigned int *ui;
+      }
+    sample;
+    size_t start;
+    size_t end;
+  };
+
+struct prof_info
+  {
+    unsigned int num_regions;
+    struct region *region;
+    struct region *last, *overflow;
+    struct itimerval saved_timer;
+    struct sigaction saved_action;
+  };
+
+static unsigned int overflow_counter;
+
+static struct region default_overflow_region +  {
+    offset:	0,
+    nsamples:	1,
+    scale:	2,
+    sample:	{ &overflow_counter },
+    start:	0,
+    end:	~(size_t) 0
+  };
+
+static struct prof_info prof_info;
+
+static inline unsigned long
+pc_to_index (size_t pc, size_t offset, unsigned int scale, int prof_uint)
+{
+  size_t i = (pc - offset)/(prof_uint ? sizeof (int) : sizeof (short));
+
+  if (sizeof (unsigned long long int) > sizeof (size_t))
+    return (unsigned long long int) i*scale/65536;
+  else
+    return i/65536*scale + i%65536*scale/65536;
+}
+
+static inline size_t
+index_to_pc (unsigned long n, size_t offset, unsigned int scale, int prof_uint)
+{
+  size_t pc, bin_size = (prof_uint ? sizeof (int) : sizeof (short));
+
+  if (sizeof (unsigned long long int) > sizeof (size_t))
+    pc = offset + n*bin_size*65536/scale;
+  else
+    pc = offset + n*bin_size/scale*65536 + n*bin_size%scale*65536/scale;
+
+  if (pc_to_index (pc, offset, scale, prof_uint) < n)
+    /* Adjust for rounding error.  */
+    ++pc;
+
+  assert (pc_to_index (pc - 1, offset, scale, prof_uint) < n
+	  && pc_to_index (pc, offset, scale, prof_uint) >= n);
+
+  return pc;
+}
+
+static inline void
+profil_count (void *pcp, int prof_uint)
+{
+  struct region *region, *r = prof_info.last;
+  size_t lo, hi, mid, pc = (unsigned long) pcp;
+  unsigned long i;
+
+  /* Fast path: pc is in same region as before.  */
+  if (pc >= r->start && pc < r->end)
+    region = r;
+  else
+    {
+      /* Slow path: do a binary search for the right region.  */
+      lo = 0; hi = prof_info.num_regions - 1;
+      while (lo <= hi)
+	{
+	  mid = (lo + hi) / 2;
+
+	  r = prof_info.region + mid;
+	  if (pc >= r->start && pc < r->end)
+	    {
+	      prof_info.last = r;
+	      region = r;
+	      break;
+	    }
+
+	  if (pc < r->start)
+	    hi = mid - 1;
+	  else
+	    lo = mid + 1;
+	}
+
+      /* No matching region: increment overflow count.  There is no point
+	 in updating the cache here, as it won't hit anyhow.  */
+      region = prof_info.overflow;
+    }
+
+  i = pc_to_index (pc, region->offset, region->scale, prof_uint);
+  if (i < r->nsamples)
+    {
+      if (prof_uint)
+	{
+	  if (r->sample.ui[i] < (unsigned int) ~0)
+	    ++r->sample.ui[i];
+	}
+      else
+	{
+	  if (r->sample.us[i] < (unsigned short) ~0)
+	    ++r->sample.us[i];
+	}
+    }
+  else
+    {
+      if (prof_uint)
+	++prof_info.overflow->sample.ui[0];
+      else
+	++prof_info.overflow->sample.us[0];
+    }
+}
+
+static inline void
+profil_count_ushort (void *pcp)
+{
+  profil_count (pcp, 0);
+}
+
+static inline void
+profil_count_uint (void *pcp)
+{
+  profil_count (pcp, 1);
+}
+
+/* Get the machine-dependent definition of `profil_counter', the signal
+   handler for SIGPROF.  It calls `profil_count' (above) with the PC of the
+   interrupted code.  */
+#define profil_counter		profil_counter_ushort
+#define profil_count(pc)	profil_count((pc), 0)
+#include "profil-counter.h"
+
+#undef profil_counter
+#undef profil_count
+
+#define profil_counter		profil_counter_uint
+#define profil_count(pc)	profil_count((pc), 1)
+#include "profil-counter.h"
+
+static int
+insert (int i, unsigned long start, unsigned long end, struct prof *p,
+	int prof_uint)
+{
+  struct region *r;
+  size_t to_copy;
+
+  if (start >= end)
+    return 0;		/* don't bother with empty regions */
+
+  if (prof_info.num_regions = 0)
+    r = malloc (sizeof (*r));
+  else
+    r = realloc (prof_info.region, (prof_info.num_regions + 1)*sizeof (*r));
+  if (!r)
+    return -1;
+
+  to_copy = prof_info.num_regions - i;
+  if (to_copy > 0)
+    memmove (r + i + 1, r + i, to_copy*sizeof (*r));
+
+  r[i].offset = p->pr_off;
+  r[i].nsamples = p->pr_size / (prof_uint ? sizeof (int) : sizeof (short));
+  r[i].scale = p->pr_scale;
+  r[i].sample.vp = p->pr_base;
+  r[i].start = start;
+  r[i].end = end;
+
+  prof_info.region = r;
+  ++prof_info.num_regions;
+
+  if (p->pr_off = 0 && p->pr_scale = 2)
+    prof_info.overflow = r;
+
+  return 0;
+}
+
+/* Add a new profiling region.  If the new region overlaps with
+   existing ones, this may add multiple subregions so that the final
+   data structure is free of overlaps.  The absence of overlaps makes
+   it possible to use a binary search in profil_count().  Note that
+   this function depends on new regions being presented in DECREASING
+   ORDER of starting address.  */
+
+static int
+add_region (struct prof *p, int prof_uint)
+{
+  unsigned long nsamples;
+  size_t start, end;
+  int i;
+
+  if (p->pr_scale < 2)
+    return 0;
+
+  nsamples = p->pr_size / (prof_uint ? sizeof (int) : sizeof (short));
+
+  start = p->pr_off;
+  end = index_to_pc (nsamples, p->pr_off, p->pr_scale, prof_uint);
+
+  /* Merge with existing regions.  */
+  for (i = 0; i < prof_info.num_regions; ++i)
+    {
+      if (start < prof_info.region[i].start)
+	{
+	  if (end < prof_info.region[i].start)
+	    break;
+	  else if (insert (i, start, prof_info.region[i].start, p, prof_uint)
+		   < 0)
+	    return -1;
+	}
+      start = prof_info.region[i].end;
+    }
+  return insert (i, start, end, p, prof_uint);
+}
+
+int
+pcmp (const void *left, const void *right)
+{
+  struct prof *l = *(struct prof **) left;
+  struct prof *r = *(struct prof **) right;
+
+  if (l->pr_off < r->pr_off)
+    return +1;
+  else if (l->pr_off > r->pr_off)
+    return -1;
+  return 0;
+}
+
+int
+__sprofil (struct prof *profp, int profcnt, struct timeval *tvp,
+	   unsigned int flags)
+{
+  struct prof *p[profcnt];
+  struct itimerval timer;
+  struct sigaction act;
+  int i;
+
+  if (tvp)
+    {
+      /* Return profiling period.  */
+      unsigned long t = 1e6 / __profile_frequency ();
+      tvp->tv_sec  = t / 1000000;
+      tvp->tv_usec = t % 1000000;
+    }
+
+  if (prof_info.num_regions > 0)
+    {
+      /* Disable profiling.  */
+      if (__setitimer (ITIMER_PROF, &prof_info.saved_timer, NULL) < 0)
+	return -1;
+
+      if (__sigaction (SIGPROF, &prof_info.saved_action, NULL) < 0)
+	return -1;
+
+      free (prof_info.region);
+      return 0;
+    }
+
+  prof_info.num_regions = 0;
+  prof_info.region = NULL;
+  prof_info.overflow = &default_overflow_region;
+
+  for (i = 0; i < profcnt; ++i)
+    p[i] = profp + i;
+
+  /* Sort in order of decreasing starting address: */
+  qsort (p, profcnt, sizeof (p[0]), pcmp);
+
+  /* Add regions in order of decreasing starting address: */
+  for (i = 0; i < profcnt; ++i)
+    if (add_region (p[i], (flags & PROF_UINT) != 0) < 0)
+      {
+	if (prof_info.region)
+	  free (prof_info.region);
+	prof_info.num_regions = 0;
+	prof_info.region = NULL;
+	return -1;
+      }
+
+  if (prof_info.num_regions = 0)
+    return 0;
+
+  prof_info.last = prof_info.region;
+
+  /* Install SIGPROF handler.  */
+  if (flags & PROF_UINT)
+    act.sa_handler = (sighandler_t) &profil_counter_uint;
+  else
+    act.sa_handler = (sighandler_t) &profil_counter_ushort;
+  act.sa_flags = SA_RESTART;
+  sigfillset (&act.sa_mask);
+  if (__sigaction (SIGPROF, &act, &prof_info.saved_action) < 0)
+    return -1;
+
+  /* Setup profiling timer.  */
+  timer.it_value.tv_sec  = 0;
+  timer.it_value.tv_usec = 1;
+  timer.it_interval = timer.it_value;
+  return __setitimer (ITIMER_PROF, &timer, &prof_info.saved_timer);
+}
+
+weak_alias (__sprofil, sprofil)
+
+#endif /* SIGPROF */

