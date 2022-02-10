From: Yury Norov <yury.norov@gmail.com>
Date: Thu, 10 Feb 2022 22:49:20 +0000
Subject: [PATCH 36/49] arch/ia64: replace cpumask_weight with cpumask_weight_eq in mm/tlb.c
Message-Id: <20220210224933.379149-37-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220210224933.379149-1-yury.norov@gmail.com>
In-Reply-To: <20220210224933.379149-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, David Laight <David.Laight@aculab.com>, Joe Perches <joe@perches.com>, Dennis Zhou <dennis@kernel.org>, Emil Renner Berthing <kernel@esmil.dk>, Nicholas Piggin <npiggin@gmail.com>, Matti Vaittinen <matti.vaittinen@fi.rohmeurope.com>, Alexey Klimov <aklimov@redhat.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

__flush_tlb_range() code calls cpumask_weight() to compare the
weight of cpumask with a given number. We can do it more efficiently with
cpumask_weight_eq because conditional cpumask_weight may stop traversing
the cpumask earlier, as soon as condition is (or can't be) met.

Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 arch/ia64/mm/tlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 135b5135cace..a5bce13ab047 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -332,7 +332,7 @@ __flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
 
 	preempt_disable();
 #ifdef CONFIG_SMP
-	if (mm != current->active_mm || cpumask_weight(mm_cpumask(mm)) != 1) {
+	if (mm != current->active_mm || !cpumask_weight_eq(mm_cpumask(mm), 1)) {
 		ia64_global_tlb_purge(mm, start, end, nbits);
 		preempt_enable();
 		return;
-- 
2.32.0
