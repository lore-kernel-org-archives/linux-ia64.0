From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:00:59 +0000
Subject: [PATCH 2/5] ia64: remove HAVE_ARCH_COPY_SIGINFO
Message-Id: <20170603190102.28866-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Since ia64 defines __ARCH_SI_PREAMBLE_SIZE it can just use the generic
copy_siginfo implementation, which is identical to the architecture
specific one.

With that support for HAVE_ARCH_COPY_SIGINFO can go away entirely.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/include/asm/siginfo.h      | 22 ----------------------
 arch/ia64/include/uapi/asm/siginfo.h |  1 -
 include/linux/signal.h               |  7 +------
 3 files changed, 1 insertion(+), 29 deletions(-)

diff --git a/arch/ia64/include/asm/siginfo.h b/arch/ia64/include/asm/siginfo.h
index 6f2e2dd0f28f..dd2f2fce976b 100644
--- a/arch/ia64/include/asm/siginfo.h
+++ b/arch/ia64/include/asm/siginfo.h
@@ -1,23 +1 @@
-/*
- * Based on <asm-i386/siginfo.h>.
- *
- * Modified 1998-2002
- *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
- */
-#ifndef _ASM_IA64_SIGINFO_H
-#define _ASM_IA64_SIGINFO_H
-
-#include <linux/string.h>
 #include <uapi/asm/siginfo.h>
-
-static inline void
-copy_siginfo (siginfo_t *to, siginfo_t *from)
-{
-	if (from->si_code < 0)
-		memcpy(to, from, sizeof(siginfo_t));
-	else
-		/* _sigchld is currently the largest know union member */
-		memcpy(to, from, 4*sizeof(int) + sizeof(from->_sifields._sigchld));
-}
-
-#endif /* _ASM_IA64_SIGINFO_H */
diff --git a/arch/ia64/include/uapi/asm/siginfo.h b/arch/ia64/include/uapi/asm/siginfo.h
index f72bf0172bb2..4694c64252d6 100644
--- a/arch/ia64/include/uapi/asm/siginfo.h
+++ b/arch/ia64/include/uapi/asm/siginfo.h
@@ -11,7 +11,6 @@
 #define __ARCH_SI_PREAMBLE_SIZE	(4 * sizeof(int))
 
 #define HAVE_ARCH_SIGINFO_T
-#define HAVE_ARCH_COPY_SIGINFO
 #define HAVE_ARCH_COPY_SIGINFO_TO_USER
 
 #include <asm-generic/siginfo.h>
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 1f5a16620693..80c7418be359 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -3,16 +3,13 @@
 
 #include <linux/bug.h>
 #include <linux/signal_types.h>
+#include <linux/string.h>
 
 struct task_struct;
 
 /* for sysctl */
 extern int print_fatal_signals;
 
-#ifndef HAVE_ARCH_COPY_SIGINFO
-
-#include <linux/string.h>
-
 static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
 {
 	if (from->si_code < 0)
@@ -22,8 +19,6 @@ static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
 		memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
 }
 
-#endif
-
 /*
  * Define some primitives to manipulate sigset_t.
  */
-- 
2.11.0

