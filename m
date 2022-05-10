From: Haowen Bai <baihaowen@meizu.com>
Date: Tue, 10 May 2022 10:01:37 +0000
Subject: [PATCH] ia64: mca: Drop redundant spinlock initialization
Message-Id: <1652176897-4754-1-git-send-email-baihaowen@meizu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1652176269-4165-1-git-send-email-baihaowen@meizu.com>
In-Reply-To: <1652176269-4165-1-git-send-email-baihaowen@meizu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: will@kernel.org, peterz@infradead.org, daniel.thompson@linaro.org, bristot@redhat.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Haowen Bai <baihaowen@meizu.com>

mlogbuf_rlock has declared and initialized by DEFINE_SPINLOCK,
so we don't need to spin_lock_init again, drop it.

Signed-off-by: Haowen Bai <baihaowen@meizu.com>
---
 arch/ia64/kernel/mca.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index e628a88607bb..c62a66710ad6 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -290,7 +290,6 @@ static void ia64_mlogbuf_finish(int wait)
 {
 	BREAK_LOGLEVEL(console_loglevel);
 
-	spin_lock_init(&mlogbuf_rlock);
 	ia64_mlogbuf_dump();
 	printk(KERN_EMERG "mlogbuf_finish: printing switched to urgent mode, "
 		"MCA/INIT might be dodgy or fail.\n");
-- 
2.7.4
