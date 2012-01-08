From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sun, 08 Jan 2012 13:32:28 +0000
Subject: [RFC PATCH v2 8/9] smp: refactor on_each_cpu to void returning func
Message-Id: <1326029549-2794-9-git-send-email-gilad@benyossef.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1326029549-2794-1-git-send-email-gilad@benyossef.com>
In-Reply-To: <1326029549-2794-1-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Grant Likely <grant.likely@secretlab.ca>, Rob Herring <rob.herring@calxeda.com>, linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

on_each_cpu returns the retunr value of smp_call_function
which is hard coded to 0.

Refactor on_each_cpu to a void function and the few callers
that check the return value to save compares and branches.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Michal Nazarewicz <mina86@mina86.com>
CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: linuxppc-dev@lists.ozlabs.org
CC: devicetree-discuss@lists.ozlabs.org
CC: Richard Henderson <rth@twiddle.net>
CC: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
CC: Matt Turner <mattst88@gmail.com>
CC: linux-alpha@vger.kernel.org
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: x86@kernel.org
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: Will Deacon <will.deacon@arm.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-arm-kernel@lists.infradead.org
---
 include/linux/smp.h |    7 +++----
 kernel/smp.c        |    6 ++----
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index 8cc38d3..050ddd4 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -99,7 +99,7 @@ static inline void call_function_init(void) { }
 /*
  * Call a function on all processors
  */
-int on_each_cpu(smp_call_func_t func, void *info, int wait);
+void on_each_cpu(smp_call_func_t func, void *info, int wait);
 
 /*
  * Mark the boot cpu "online" so that it can call console drivers in
@@ -126,12 +126,11 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
 #define smp_call_function(func, info, wait) \
 			(up_smp_call_function(func, info))
 #define on_each_cpu(func,info,wait)		\
-	({					\
+	{					\
 		local_irq_disable();		\
 		func(info);			\
 		local_irq_enable();		\
-		0;				\
-	})
+	}
 static inline void smp_send_reschedule(int cpu) { }
 #define num_booting_cpus()			1
 #define smp_prepare_boot_cpu()			do {} while (0)
diff --git a/kernel/smp.c b/kernel/smp.c
index db197d6..f66a1b2 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -687,17 +687,15 @@ void __init smp_init(void)
  * early_boot_irqs_disabled is set.  Use local_irq_save/restore() instead
  * of local_irq_disable/enable().
  */
-int on_each_cpu(void (*func) (void *info), void *info, int wait)
+void on_each_cpu(void (*func) (void *info), void *info, int wait)
 {
 	unsigned long flags;
-	int ret = 0;
 
 	preempt_disable();
-	ret = smp_call_function(func, info, wait);
+	smp_call_function(func, info, wait);
 	local_irq_save(flags);
 	func(info);
 	local_irq_restore(flags);
 	preempt_enable();
-	return ret;
 }
 EXPORT_SYMBOL(on_each_cpu);
-- 
1.7.0.4

