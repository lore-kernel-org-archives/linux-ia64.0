From: Jeffrey Merkey <jeffmerkey@gmail.com>
Date: Thu, 28 Jan 2016 19:46:23 +0000
Subject: [PATCH 05/31] Add debugger entry points for IA64
Message-Id: <1454010383-28585-1-git-send-email-jeffmerkey@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux.mdb@gmail.com, linux-ia64@vger.kernel.org

This patch series adds an export which can be set by system debuggers to
direct the hard lockup and soft lockup detector to trigger a breakpoint
exception and enter a debugger if one is active.  It is assumed that if
someone sets this variable, then an breakpoint handler of some sort will
be actively loaded or registered via the notify die handler chain.

This addition is extremely useful for debugging hard and soft lockups
real time and quickly from a console debugger.

Signed-off-by: Jeffrey Merkey <jeffmerkey@gmail.com>
---
 arch/ia64/include/asm/kdebug.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/ia64/include/asm/kdebug.h b/arch/ia64/include/asm/kdebug.h
index d11a698..8866d8d 100644
--- a/arch/ia64/include/asm/kdebug.h
+++ b/arch/ia64/include/asm/kdebug.h
@@ -54,4 +54,8 @@ enum die_val {
 	DIE_KDUMP_LEAVE,
 };
 
+static inline void arch_breakpoint(void)
+{
+}
+
 #endif
-- 
1.8.3.1

