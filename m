From: Jan Kara <jack@suse.com>
Date: Tue, 06 Oct 2015 09:24:25 +0000
Subject: [PATCH 2/7] ia64: Use get_user_pages_fast() in err_inject.c
Message-Id: <1444123470-4932-3-git-send-email-jack@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

From: Jan Kara <jack@suse.cz>

Convert get_user_pages() call to get_user_pages_fast(). This actually
fixes an apparent bug where get_user_pages() has been called without
mmap_sem for an arbitrary user-provided address.

CC: Tony Luck <tony.luck@intel.com>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/ia64/kernel/err_inject.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 0c161ed6d18e..1fc8995bd8b8 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -142,8 +142,7 @@ store_virtual_to_phys(struct device *dev, struct device_attribute *attr,
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-        ret = get_user_pages(current, current->mm, virt_addr,
-                        1, VM_READ, 0, NULL, NULL);
+	ret = get_user_pages_fast(virt_addr, 1, VM_READ, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
-- 
2.1.4

