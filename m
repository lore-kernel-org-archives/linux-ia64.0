From: wency@cn.fujitsu.com
Date: Tue, 28 Aug 2012 10:00:27 +0000
Subject: [RFC v8 PATCH 20/20] memory-hotplug: clear hwpoisoned flag when onlining pages
Message-Id: <1346148027-24468-21-git-send-email-wency@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

hwpoisoned may set when we offline a page by the sysfs interface
/sys/devices/system/memory/soft_offline_page or
/sys/devices/system/memory/hard_offline_page. If we don't clear
this flag when onlining pages, this page can't be freed, and will
not in free list. So we can't offline these pages again. So we
should clear this flag when onlining pages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index fb8af64..85603c4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -661,6 +661,11 @@ EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
+#ifdef CONFIG_MEMORY_FAILURE
+	/* The page may be marked HWPoisoned by soft/hard offline page */
+	ClearPageHWPoison(page);
+#endif
+
 	ClearPageReserved(page);
 	init_page_count(page);
 	__free_page(page);
-- 
1.7.1

