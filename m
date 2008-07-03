From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 06:54:37 +0000
Subject: [PATCH] ia64: move function declaration, ia64_cpu_local_tick() from .c to .h
Message-Id: <12150681053484-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

eliminate the function declaration ia64_cpu_local_tick() in
process.c by defining in asm-ia64/timex.h
The same function will be used in a different .c file later.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/process.c |    1 -
 include/asm-ia64/timex.h   |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index a3a34b4..1fbd9b8 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -247,7 +247,6 @@ default_idle (void)
 /* We don't actually take CPU down, just spin without interrupts. */
 static inline void play_dead(void)
 {
-	extern void ia64_cpu_local_tick (void);
 	unsigned int this_cpu = smp_processor_id();
 
 	/* Ack it */
diff --git a/include/asm-ia64/timex.h b/include/asm-ia64/timex.h
index 05a6baf..4e03cfe 100644
--- a/include/asm-ia64/timex.h
+++ b/include/asm-ia64/timex.h
@@ -39,4 +39,6 @@ get_cycles (void)
 	return ret;
 }
 
+extern void ia64_cpu_local_tick (void);
+
 #endif /* _ASM_IA64_TIMEX_H */
-- 
1.5.3

