From: Jonas Rabenstein <ve92mose@stud.informatik.uni-erlangen.de>
Date: Wed, 06 Apr 2016 23:13:00 +0000
Subject: [PATCH 2/3] ia64: remove unused asm/idle.h
Message-Id: <ae61bf3277096aacfa94e25589d6fedf76a9ff39.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
In-Reply-To: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

From: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

The file arch/ia64/include/asm/idle.h can not be included by any file
and as a consequence may be removed from the source tree.
Currently five files have #includes for asm/idle.h:
drivers/cpufreq/loongson2_cpufreq.c:
        depends on LOONGSON2 (mips)
drivers/cpuidle/cpuidle-cps.c:
        depends on MIPS_CPS_CPUIDLE (mips)
drivers/idle/i7300_idle.c:
        depends on X86_64
drivers/thermal/intel_powerclamp.c:
        depends on X86
drivers/xen/events/events_base.c:
        depends on XEN (arm/x86)

Signed-off-by: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>
---
 arch/ia64/include/asm/idle.h | 7 -------
 1 file changed, 7 deletions(-)
 delete mode 100644 arch/ia64/include/asm/idle.h

diff --git a/arch/ia64/include/asm/idle.h b/arch/ia64/include/asm/idle.h
deleted file mode 100644
index b768501..0000000
--- a/arch/ia64/include/asm/idle.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _ASM_IA64_IDLE_H
-#define _ASM_IA64_IDLE_H
-
-static inline void enter_idle(void) { }
-static inline void exit_idle(void) { }
-
-#endif /* _ASM_IA64_IDLE_H */
-- 
1.9.1

