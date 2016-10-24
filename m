From: Colin King <colin.king@canonical.com>
Date: Mon, 24 Oct 2016 22:36:42 +0000
Subject: [PATCH] ia64, err-inject: fix spelling mistake: "capapbilities" -> "capabilities"
Message-Id: <20161024223642.10142-1-colin.king@canonical.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Jesper Nilsson <jesper.nilsson@axis.com>, Jan Kara <jack@suse.cz>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in printk debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 arch/ia64/kernel/err_inject.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 5ed0ea9..a18e0b4 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -117,7 +117,7 @@ store_call_start(struct device *dev, struct device_attribute *attr,
 
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_DEBUG "Returns: status=%d,\n", (int)status[cpu]);
-	printk(KERN_DEBUG "capapbilities=%lx,\n", capabilities[cpu]);
+	printk(KERN_DEBUG "capabilities=%lx,\n", capabilities[cpu]);
 	printk(KERN_DEBUG "resources=%lx\n", resources[cpu]);
 #endif
 	return size;
-- 
2.9.3

