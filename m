From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 00:14:11 +0000
Subject: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for per cpu access
Message-Id: <20071127001430.083503280@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

The model(small) attribute is not supported by gcc 4.X. The tests
will always be negative today.

Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/ia64/scripts/check-model.c   |    1 -
 arch/ia64/scripts/toolchain-flags |    6 ------
 include/asm-ia64/percpu.h         |   12 +++---------
 3 files changed, 3 insertions(+), 16 deletions(-)

Index: linux-2.6/include/asm-ia64/percpu.h
=================================--- linux-2.6.orig/include/asm-ia64/percpu.h	2007-11-22 15:55:47.634454755 -0800
+++ linux-2.6/include/asm-ia64/percpu.h	2007-11-22 15:56:15.974704716 -0800
@@ -15,24 +15,18 @@
 
 #include <linux/threads.h>
 
-#ifdef HAVE_MODEL_SMALL_ATTRIBUTE
-# define __SMALL_ADDR_AREA	__attribute__((__model__ (__small__)))
-#else
-# define __SMALL_ADDR_AREA
-#endif
-
 #define DECLARE_PER_CPU(type, name)				\
-	extern __SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
+	extern __typeof__(type) per_cpu__##name
 
 /* Separate out the type, so (int[3], foo) works. */
 #define DEFINE_PER_CPU(type, name)				\
 	__attribute__((__section__(".data.percpu")))		\
-	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
+	__typeof__(type) per_cpu__##name
 
 #ifdef CONFIG_SMP
 #define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
 	__attribute__((__section__(".data.percpu.shared_aligned")))	\
-	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name		\
+	__typeof__(type) per_cpu__##name				\
 	____cacheline_aligned_in_smp
 #else
 #define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
Index: linux-2.6/arch/ia64/scripts/check-model.c
=================================--- linux-2.6.orig/arch/ia64/scripts/check-model.c	2007-11-22 15:56:40.890455063 -0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1 +0,0 @@
-int __attribute__ ((__model__ (__small__))) x;
Index: linux-2.6/arch/ia64/scripts/toolchain-flags
=================================--- linux-2.6.orig/arch/ia64/scripts/toolchain-flags	2007-11-22 15:57:07.329204964 -0800
+++ linux-2.6/arch/ia64/scripts/toolchain-flags	2007-11-22 15:57:27.229018356 -0800
@@ -35,12 +35,6 @@ if [ $res -eq 0 ]; then
     CPPFLAGS="$CPPFLAGS -DHAVE_WORKING_TEXT_ALIGN"
 fi
 
-if ! $CC -c $dir/check-model.c -o $out 2>&1 | grep  __model__ | grep -q attrib
-then
-    CPPFLAGS="$CPPFLAGS -DHAVE_MODEL_SMALL_ATTRIBUTE"
-fi
-rm -f $out
-
 # Check whether assembler supports .serialize.{data,instruction} directive.
 
 $CC -c $dir/check-serialize.S -o $out 2>/dev/null

-- 
