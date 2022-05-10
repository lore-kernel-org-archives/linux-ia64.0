From: Yury Norov <yury.norov@gmail.com>
Date: Tue, 10 May 2022 15:47:40 +0000
Subject: [PATCH 12/22] ia64: cleanup remove_siblinginfo()
Message-Id: <20220510154750.212913-13-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220510154750.212913-1-yury.norov@gmail.com>
In-Reply-To: <20220510154750.212913-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, David Laight <David.Laight@ACULAB.COM>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joe Perches <joe@perches.com>, Julia Lawall <Julia.Lawall@inria.fr>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, Nicholas Piggin <npiggin@gmail.com>, Nicolas Palix <nicolas.palix@imag.fr>, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matti Vaittinen <Matti.Vaittinen@fi.rohmeurope.com>, linux-kernel@vger.kernel.org
Cc: Yury Norov <yury.norov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Valentin Schneider <vschneid@redhat.com>, linux-ia64@vger.kernel.org

remove_siblinginfo() initialises variable 'last', but never uses it.
Drop unneeded code.

CC: Ingo Molnar <mingo@kernel.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Valentin Schneider <vschneid@redhat.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 arch/ia64/kernel/smpboot.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index d10f780c13b9..d0e935cf2093 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -576,8 +576,6 @@ clear_cpu_sibling_map(int cpu)
 static void
 remove_siblinginfo(int cpu)
 {
-	int last = 0;
-
 	if (cpu_data(cpu)->threads_per_core = 1 &&
 	    cpu_data(cpu)->cores_per_socket = 1) {
 		cpumask_clear_cpu(cpu, &cpu_core_map[cpu]);
@@ -585,8 +583,6 @@ remove_siblinginfo(int cpu)
 		return;
 	}
 
-	last = (cpumask_weight(&cpu_core_map[cpu]) = 1 ? 1 : 0);
-
 	/* remove it from all sibling map's */
 	clear_cpu_sibling_map(cpu);
 }
-- 
2.32.0
