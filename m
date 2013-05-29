From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 29 May 2013 10:05:18 +0000
Subject: [PATCH] ia64: use %*phD specifier to dump small buffers
Message-Id: <1369821918-3935-1-git-send-email-andriy.shevchenko@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

pfm_uuid_t value is defined as unsigned char [16]. Thus, we may dump its value
as byte buffer using %*phD specifier.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 arch/ia64/kernel/perfmon.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 9ea25fc..5a9ff1c 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -5647,24 +5647,8 @@ pfm_proc_show_header(struct seq_file *m)
 
 	list_for_each(pos, &pfm_buffer_fmt_list) {
 		entry = list_entry(pos, pfm_buffer_fmt_t, fmt_list);
-		seq_printf(m, "format                    : %02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x %s\n",
-			entry->fmt_uuid[0],
-			entry->fmt_uuid[1],
-			entry->fmt_uuid[2],
-			entry->fmt_uuid[3],
-			entry->fmt_uuid[4],
-			entry->fmt_uuid[5],
-			entry->fmt_uuid[6],
-			entry->fmt_uuid[7],
-			entry->fmt_uuid[8],
-			entry->fmt_uuid[9],
-			entry->fmt_uuid[10],
-			entry->fmt_uuid[11],
-			entry->fmt_uuid[12],
-			entry->fmt_uuid[13],
-			entry->fmt_uuid[14],
-			entry->fmt_uuid[15],
-			entry->fmt_name);
+		seq_printf(m, "format                    : %16phD %s\n",
+			   entry->fmt_uuid, entry->fmt_name);
 	}
 	spin_unlock(&pfm_buffer_fmt_lock);
 
-- 
1.8.2.rc0.22.gb3600c3

