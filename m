From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Tue, 23 Mar 2021 22:40:09 +0000
Subject: [PATCH] ia64: drop unused IA64_FW_EMU ifdef
Message-Id: <20210323224009.240625-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org

It's a remnant of deleted hpsim emulation target
removed in fc5bad037 ("ia64: remove the hpsim platform").

CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/kernel/head.S | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 646a22c25edf..9cd0a2cce36e 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -405,11 +405,6 @@ start_ap:
 
 	// This is executed by the bootstrap processor (bsp) only:
 
-#ifdef CONFIG_IA64_FW_EMU
-	// initialize PAL & SAL emulator:
-	br.call.sptk.many rp=sys_fw_init
-.ret1:
-#endif
 	br.call.sptk.many rp=start_kernel
 .ret2:	addl r3=@ltoff(halt_msg),gp
 	;;
-- 
2.31.0
