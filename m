From: James Hogan <james.hogan@imgtec.com>
Date: Mon, 08 Feb 2016 18:43:50 +0000
Subject: [PATCH 2/3] signal: Move generic copy_siginfo() to signal.h
Message-Id: <1454957031-20138-3-git-send-email-james.hogan@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454957031-20138-1-git-send-email-james.hogan@imgtec.com>
In-Reply-To: <1454957031-20138-1-git-send-email-james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-kernel@vger.kernel.org, Christopher Ferris <cferris@google.com>, James Hogan <james.hogan@imgtec.com>, Arnd Bergmann <arnd@arndb.de>, Petr Malat <oss@malat.biz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, stable@vger.kernel.org

The generic copy_siginfo() is currently defined in
asm-generic/siginfo.h, after including uapi/asm-generic/siginfo.h which
defines the generic struct siginfo. However this makes it awkward for an
architecture to use it if it has to define its own struct siginfo (e.g.
MIPS and potentially IA64), since it means that asm-generic/siginfo.h
can only be included after defining the arch-specific siginfo, which may
be problematic if the arch-specific definition needs definitions from
uapi/asm-generic/siginfo.h.

It is possible to work around this by first including
uapi/asm-generic/siginfo.h to get the constants before defining the
arch-specific siginfo, and include asm-generic/siginfo.h after. However
uapi headers can't be included by other uapi headers, so that first
include has to be in an ifdef __kernel__, with the non __kernel__ case
including the non-UAPI header instead.

Instead of that mess, move the generic copy_siginfo() definition into
linux/signal.h, which allows an arch-specific uapi/asm/siginfo.h to
include asm-generic/siginfo.h and define the arch-specific siginfo, and
for the generic copy_siginfo() to see that arch-specific definition.

Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Petr Malat <oss@malat.biz>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-ia64@vger.kernel.org
Cc: <stable@vger.kernel.org> # 4.0-
---
 include/asm-generic/siginfo.h | 15 ---------------
 include/linux/signal.h        | 15 +++++++++++++++
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
index 3d1a3af5cf59..a2508a8f9a9c 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -17,21 +17,6 @@
 struct siginfo;
 void do_schedule_next_timer(struct siginfo *info);
 
-#ifndef HAVE_ARCH_COPY_SIGINFO
-
-#include <linux/string.h>
-
-static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
-{
-	if (from->si_code < 0)
-		memcpy(to, from, sizeof(*to));
-	else
-		/* _sigchld is currently the largest know union member */
-		memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
-}
-
-#endif
-
 extern int copy_siginfo_to_user(struct siginfo __user *to, const struct siginfo *from);
 
 #endif
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 92557bbce7e7..d80259afb9e5 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -28,6 +28,21 @@ struct sigpending {
 	sigset_t signal;
 };
 
+#ifndef HAVE_ARCH_COPY_SIGINFO
+
+#include <linux/string.h>
+
+static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
+{
+	if (from->si_code < 0)
+		memcpy(to, from, sizeof(*to));
+	else
+		/* _sigchld is currently the largest know union member */
+		memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
+}
+
+#endif
+
 /*
  * Define some primitives to manipulate sigset_t.
  */
-- 
2.4.10

