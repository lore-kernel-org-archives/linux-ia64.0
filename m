From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Apr 2008 07:50:22 +0000
Subject: [PATCH] ia64: fix section mismatch in arch/ia64/kernel/palinfo.c
Message-Id: <481824BE.2000409@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch removes following warning:

	WARNING: vmlinux.o(.exit.text+0xb1): Section mismatch in
	reference from the function palinfo_exit() to the variable
	.cpuinit.data:palinfo_cpu_notifier

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/palinfo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 396004e..4547a20 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -1053,7 +1053,7 @@ static int __cpuinit palinfo_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block palinfo_cpu_notifier __cpuinitdata +static struct notifier_block __refdata palinfo_cpu_notifier  {
 	.notifier_call = palinfo_cpu_callback,
 	.priority = 0,
