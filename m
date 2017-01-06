From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 06 Jan 2017 09:43:54 +0000
Subject: [PATCH v2 2/7] h8300: put bitsperlong.h in uapi
Message-Id: <1483695839-18660-3-git-send-email-nicolas.dichtel@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-me

This header file is exported, thus move it to uapi.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/h8300/include/asm/bitsperlong.h      | 10 +---------
 arch/h8300/include/uapi/asm/bitsperlong.h | 14 ++++++++++++++
 2 files changed, 15 insertions(+), 9 deletions(-)
 create mode 100644 arch/h8300/include/uapi/asm/bitsperlong.h

diff --git a/arch/h8300/include/asm/bitsperlong.h b/arch/h8300/include/asm/bitsperlong.h
index e140e46729ac..c0a8e2ee531e 100644
--- a/arch/h8300/include/asm/bitsperlong.h
+++ b/arch/h8300/include/asm/bitsperlong.h
@@ -1,14 +1,6 @@
 #ifndef __ASM_H8300_BITS_PER_LONG
 #define __ASM_H8300_BITS_PER_LONG
 
-#include <asm-generic/bitsperlong.h>
-
-#if !defined(__ASSEMBLY__)
-/* h8300-unknown-linux required long */
-#define __kernel_size_t __kernel_size_t
-typedef unsigned long	__kernel_size_t;
-typedef long		__kernel_ssize_t;
-typedef long		__kernel_ptrdiff_t;
-#endif
+#include <uapi/asm/bitsperlong.h>
 
 #endif /* __ASM_H8300_BITS_PER_LONG */
diff --git a/arch/h8300/include/uapi/asm/bitsperlong.h b/arch/h8300/include/uapi/asm/bitsperlong.h
new file mode 100644
index 000000000000..e56cf72369b6
--- /dev/null
+++ b/arch/h8300/include/uapi/asm/bitsperlong.h
@@ -0,0 +1,14 @@
+#ifndef _UAPI_ASM_H8300_BITS_PER_LONG
+#define _UAPI_ASM_H8300_BITS_PER_LONG
+
+#include <asm-generic/bitsperlong.h>
+
+#if !defined(__ASSEMBLY__)
+/* h8300-unknown-linux required long */
+#define __kernel_size_t __kernel_size_t
+typedef unsigned long	__kernel_size_t;
+typedef long		__kernel_ssize_t;
+typedef long		__kernel_ptrdiff_t;
+#endif
+
+#endif /* _UAPI_ASM_H8300_BITS_PER_LONG */
-- 
2.8.1

