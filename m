From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 07 Sep 2010 14:33:34 +0000
Subject: [patch 24/30] ia64: salinfo: sema_init instead of init_MUTEX
Message-Id: <20100907125056.990178973@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100907124636.880953480@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org

---
 arch/ia64/kernel/salinfo.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/kernel/salinfo.c
=================================--- linux-2.6.orig/arch/ia64/kernel/salinfo.c
+++ linux-2.6/arch/ia64/kernel/salinfo.c
@@ -642,7 +642,7 @@ salinfo_init(void)
 	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
 		data = salinfo_data + i;
 		data->type = i;
-		init_MUTEX(&data->mutex);
+		sema_init(&data->mutex, 1);
 		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
 		if (!dir)
 			continue;


