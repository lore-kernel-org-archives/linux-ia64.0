From: Tony Luck <tony.luck@intel.com>
Date: Mon, 15 Sep 2014 16:32:23 +0000
Subject: [PATCH] [IA64] Fix syscall number for memfd_create
Message-Id: <018710@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cut & paste typo from the line above.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/uapi/asm/unistd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index 6a65bb7d0657..18026b2eb582 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -329,6 +329,6 @@
 #define __NR_sched_getattr		1337
 #define __NR_renameat2			1338
 #define __NR_getrandom			1339
-#define __NR_memfd_create		1339
+#define __NR_memfd_create		1340
 
 #endif /* _UAPI_ASM_IA64_UNISTD_H */
-- 
1.8.4.1

