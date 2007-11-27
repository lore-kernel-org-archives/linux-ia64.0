From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 01:37:38 +0000
Subject: Re: [patch 13/14] ia64: Use generic percpu
Message-Id: <Pine.LNX.4.64.0711261735001.29915@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com> <20071127001432.160399113@sgi.com>
In-Reply-To: <20071127001432.160399113@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

Duh. This particular patch assumes already relocated per cpu areas which 
does not work with ia64's per cpu area mapings. This fix is needed:

---
 include/asm-ia64/percpu.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/include/asm-ia64/percpu.h
=================================--- linux-2.6.orig/include/asm-ia64/percpu.h	2007-11-26 17:14:22.823022434 -0800
+++ linux-2.6/include/asm-ia64/percpu.h	2007-11-26 17:18:34.063021793 -0800
@@ -9,7 +9,7 @@
 #define PERCPU_ENOUGH_ROOM PERCPU_PAGE_SIZE
 
 #ifdef __ASSEMBLY__
-# define THIS_CPU(var)	(PERCPU_ADDR + per_cpu__##var)  /* use this to mark accesses to per-CPU variables... */
+# define THIS_CPU(var)	per_cpu__##var  /* use this to mark accesses to per-CPU variables... */
 #else /* !__ASSEMBLY__ */
 
 #include <linux/threads.h>
@@ -35,7 +35,7 @@ extern void *per_cpu_init(void);
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	(*SHIFT_PTR(&per_cpu__##var, PERCPU_ADDR))
+#define __ia64_per_cpu_var(var)	per_cpu__##var
 
 #include <asm-generic/percpu.h>
 
