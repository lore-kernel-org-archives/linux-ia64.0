From: Firoz Khan <firoz.khan@linaro.org>
Date: Thu, 27 Sep 2018 14:27:20 +0000
Subject: [PATCH v2 7/7] ia64: add __IGNORE* entries in asm/unistd.h
Message-Id: <1538057720-3392-8-git-send-email-firoz.khan@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org, firoz.khan@linaro.org

Add __IGNORE* entries for perf_event_open, seccomp, pkey_
mprotect, pkey_alloc, pkey_free, statx, io_pgetevents and
rseq in the file asm/unistd.h as it is correct to keep
__IGNORE* entry in non uapi header asm/unistd.h while uapi/
asm/unistd.h must hold information only useful for user
space applications.

Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
---
 arch/ia64/include/asm/unistd.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 397b143..a0941e6 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -26,6 +26,15 @@
 #define __IGNORE_vfork		/* clone() */
 #define __IGNORE_umount2	/* umount() */
 
+#define __IGNORE_perf_event_open
+#define __IGNORE_seccomp
+#define __IGNORE_pkey_mprotect
+#define __IGNORE_pkey_alloc
+#define __IGNORE_pkey_free
+#define __IGNORE_statx
+#define __IGNORE_io_pgetevents
+#define __IGNORE_rseq
+
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
 
 #include <linux/types.h>
-- 
1.9.1
