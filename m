From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 21:43:39 +0000
Subject: [patch 3/4] ia64 UV: use blinking LED for heartbeat display
Message-Id: <200809222143.m8MLhd1D031425@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Mike Travis <travis@sgi.com>

  * Add a function to blink the "heartbeat" LED indicating
    that the CPU is responding to timer interrupts.

  * Introduces a callback for "heartbeat" display in the
    clocksource_watchdog function, which in turn requires
    CONFIG_CLOCKSOURCE_WATCHDOG to be set.

Note that this is a RAS feature that allows external monitoring of
various cpu state indicators, not just providing "pretty blinking
lights", as the LED state is readable by the system controller.

Signed-off-by: Mike Travis <travis@sgi.com>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/include/asm/uv/uv_hub.h |    4 ++++
 arch/ia64/uv/kernel/setup.c       |   28 ++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff -puN arch/ia64/include/asm/uv/uv_hub.h~ia64-uv-use-blinking-led-for-heartbeat-display arch/ia64/include/asm/uv/uv_hub.h
--- a/arch/ia64/include/asm/uv/uv_hub.h~ia64-uv-use-blinking-led-for-heartbeat-display
+++ a/arch/ia64/include/asm/uv/uv_hub.h
@@ -100,6 +100,7 @@ struct uv_hub_info_s {
 	unsigned long	lowmem_remap_top;
 	unsigned long	lowmem_remap_base;
 	unsigned long	led_offset;
+	unsigned int	led_heartbeat_count;
 	unsigned short	pnode;
 	unsigned short	pnode_mask;
 	unsigned short	coherency_domain_number;
@@ -153,6 +154,9 @@ DECLARE_PER_CPU(struct uv_hub_info_s, __
 /* idle callback */
 extern void (*ia64_mark_idle) (int);
 
+/* idle callback */
+extern void (*ia64_mark_idle) (int);
+
 /*
  * Macros for converting between kernel virtual addresses, socket local physical
  * addresses, and UV global physical addresses.
diff -puN arch/ia64/uv/kernel/setup.c~ia64-uv-use-blinking-led-for-heartbeat-display arch/ia64/uv/kernel/setup.c
--- a/arch/ia64/uv/kernel/setup.c~ia64-uv-use-blinking-led-for-heartbeat-display
+++ a/arch/ia64/uv/kernel/setup.c
@@ -8,6 +8,7 @@
  * Copyright (C) 2008 Silicon Graphics, Inc. All rights reserved.
  */
 
+#include <linux/clocksource.h>
 #include <linux/module.h>
 #include <linux/percpu.h>
 #include <asm/sn/simulator.h>
@@ -65,6 +66,25 @@ static void uv_idle(int state)
 		uv_set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
 }
 
+#ifdef CONFIG_CLOCKSOURCE_WATCHDOG
+static void uv_display_heartbeat(void)
+{
+	int cpu;
+
+	uv_hub_info->led_heartbeat_count = nr_cpu_ids;
+
+	for_each_online_cpu(cpu) {
+		struct uv_hub_info_s *hub = uv_cpu_hub_info(cpu);
+
+		if (hub->led_heartbeat_count > 0) {
+			uv_set_led_bits_on(cpu, LED_CPU_BLINK,
+						LED_CPU_HEARTBEAT);
+			--hub->led_heartbeat_count;
+		}
+	}
+}
+#endif
+
 void __init uv_setup(char **cmdline_p)
 {
 	union uvh_si_addr_map_config_u m_n_config;
@@ -124,4 +144,12 @@ void __init uv_setup(char **cmdline_p)
 
 	/* enable idle callback */
 	ia64_mark_idle = &uv_idle;
+
+#ifdef CONFIG_CLOCKSOURCE_WATCHDOG
+	/* enable heartbeat display callback */
+	display_heartbeat = uv_display_heartbeat;
+#else
+	printk(KERN_NOTICE "UV: CLOCKSOURCE_WATCHDOG not configured, "
+			   "LED Heartbeat NOT enabled\n");
+#endif
 }
_
