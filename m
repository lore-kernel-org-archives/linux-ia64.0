From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 15:05:43 +0000
Subject: [PATCH 3/3] ia64, palinfo: Remove bogus __refdata annotation
Message-Id: <1437318343-13152-4-git-send-email-minipli@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The __cpuinit annotation was dropped from palinfo_cpu_callback() in
commit ccce9bb83ed2 ("[IA64] Delete __cpuinit usage from all ia64
users"), vanishing the need for palinfo_cpu_notifier to be annotated
with __refdata.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/kernel/palinfo.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index c39c3cd3ac34..3c77738fc570 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -980,7 +980,7 @@ static int palinfo_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block __refdata palinfo_cpu_notifier +static struct notifier_block palinfo_cpu_notifier  {
 	.notifier_call = palinfo_cpu_callback,
 	.priority = 0,
-- 
1.7.10.4

