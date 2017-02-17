From: Joe Perches <joe@perches.com>
Date: Fri, 17 Feb 2017 07:11:18 +0000
Subject: [PATCH 05/35] ia64: Convert remaining use of pr_warning to pr_warn
Message-Id: <b10feda6efbf0528ea1e1bbc64f1673d3eeee1c7.1487314667.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1487314666.git.joe@perches.com>
In-Reply-To: <cover.1487314666.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

To enable eventual removal of pr_warning

This makes pr_warn use consistent for arch/ia64

Prior to this patch, there was 1 use of pr_warning and
1 use of pr_warn in arch/ia64

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/setup.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index d68322966f33..8593d93fbbd7 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -294,11 +294,9 @@ static void __init setup_crashkernel(unsigned long total, int *n)
 		}
 
 		if (!check_crashkernel_memory(base, size)) {
-			pr_warning("crashkernel: There would be kdump memory "
-				"at %ld GB but this is unusable because it "
-				"must\nbe below 4 GB. Change the memory "
-				"configuration of the machine.\n",
+			pr_warn("crashkernel: There would be kdump memory at %ld GB but this is unusable because it must be below 4 GB.\n",
 				(unsigned long)(base >> 30));
+			pr_warn("crashkernel: Change the memory configuration of the machine.\n");
 			return;
 		}
 
-- 
2.10.0.rc2.1.g053435c

