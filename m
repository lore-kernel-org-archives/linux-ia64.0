From: "Justin P. Mattock" <justinmattock@gmail.com>
Date: Wed, 02 Feb 2011 05:05:30 +0000
Subject: [PATCH 1/8]arch:ia64:perfmon.h change a typo comamnd to command
Message-Id: <1296623130-5130-1-git-send-email-justinmattock@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trivial@kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Justin P. Mattock" <justinmattock@gmail.com>

The below patch fixes a typo comamnd to command.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 arch/ia64/include/asm/perfmon.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/perfmon.h b/arch/ia64/include/asm/perfmon.h
index 7f3333d..d551183 100644
--- a/arch/ia64/include/asm/perfmon.h
+++ b/arch/ia64/include/asm/perfmon.h
@@ -7,7 +7,7 @@
 #define _ASM_IA64_PERFMON_H
 
 /*
- * perfmon comamnds supported on all CPU models
+ * perfmon commands supported on all CPU models
  */
 #define PFM_WRITE_PMCS		0x01
 #define PFM_WRITE_PMDS		0x02
-- 
1.6.5.GIT

