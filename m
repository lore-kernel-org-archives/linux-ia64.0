From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:49 +0000
Subject: [PATCH 29/29] genirq: remove the is_affinity_mask_valid hook
Message-Id: <20190807133049.20893-30-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This override was only used by the ia64 SGI SN2 platform, which is
gone now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/irq/proc.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index da9addb8d655..cfc4f088a0e7 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -100,10 +100,6 @@ static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-#ifndef is_affinity_mask_valid
-#define is_affinity_mask_valid(val) 1
-#endif
-
 int no_irq_affinity;
 static int irq_affinity_proc_show(struct seq_file *m, void *v)
 {
@@ -136,11 +132,6 @@ static ssize_t write_irq_affinity(int type, struct file *file,
 	if (err)
 		goto free_cpumask;
 
-	if (!is_affinity_mask_valid(new_value)) {
-		err = -EINVAL;
-		goto free_cpumask;
-	}
-
 	/*
 	 * Do not allow disabling IRQs completely - it's a too easy
 	 * way to make the system unusable accidentally :-) At least
@@ -232,11 +223,6 @@ static ssize_t default_affinity_write(struct file *file,
 	if (err)
 		goto out;
 
-	if (!is_affinity_mask_valid(new_value)) {
-		err = -EINVAL;
-		goto out;
-	}
-
 	/*
 	 * Do not allow disabling IRQs completely - it's a too easy
 	 * way to make the system unusable accidentally :-) At least
-- 
2.20.1
