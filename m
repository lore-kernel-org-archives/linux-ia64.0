From: Yury Norov <yury.norov@gmail.com>
Date: Thu, 10 Feb 2022 22:48:59 +0000
Subject: [PATCH 15/49] arch/ia64: replace cpumask_weight with cpumask_empty where appropriate
Message-Id: <20220210224933.379149-16-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220210224933.379149-1-yury.norov@gmail.com>
In-Reply-To: <20220210224933.379149-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, David Laight <David.Laight@aculab.com>, Joe Perches <joe@perches.com>, Dennis Zhou <dennis@kernel.org>, Emil Renner Berthing <kernel@esmil.dk>, Nicholas Piggin <npiggin@gmail.com>, Matti Vaittinen <matti.vaittinen@fi.rohmeurope.com>, Alexey Klimov <aklimov@redhat.com>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, Yang Guang <yang.guang5@zte.com.cn>, linux-ia64@vger.kernel.org

setup_arch() calls cpumask_weight() to check if any bit of a given cpumask
is set. We can do it more efficiently with cpumask_empty() because
cpumask_empty() stops traversing the cpumask as soon as it finds first set
bit, while cpumask_weight() counts all bits unconditionally.

Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 arch/ia64/kernel/setup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 5010348fa21b..fd6301eafa9d 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -572,7 +572,7 @@ setup_arch (char **cmdline_p)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
 #endif
-	per_cpu_scan_finalize((cpumask_weight(&early_cpu_possible_map) = 0 ?
+	per_cpu_scan_finalize((cpumask_empty(&early_cpu_possible_map) ?
 		32 : cpumask_weight(&early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
 #endif /* CONFIG_ACPI_NUMA */
-- 
2.32.0
