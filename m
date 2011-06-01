From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Wed, 01 Jun 2011 09:48:17 +0000
Subject: [PATCH] ia64: Hook up gpiolib support
Message-Id: <1306921697-31045-1-git-send-email-broonie@opensource.wolfsonmicro.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Allow people to use gpiolib on ia64, mostly for build coverage as it
seems more useful to standardise on availablity of the API than handle
it being optional.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 arch/ia64/Kconfig            |    4 +++
 arch/ia64/include/asm/gpio.h |   55 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/gpio.h

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 38280ef..dbffa42 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -27,6 +27,7 @@ config IA64
 	select GENERIC_PENDING_IRQ if SMP
 	select IRQ_PER_CPU
 	select GENERIC_IRQ_SHOW
+	select ARCH_WANT_OPTINAL_GPIOLIB
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
@@ -89,6 +90,9 @@ config GENERIC_TIME_VSYSCALL
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
+config GENERIC_GPIO
+	def_bool y
+
 config DMI
 	bool
 	default y
diff --git a/arch/ia64/include/asm/gpio.h b/arch/ia64/include/asm/gpio.h
new file mode 100644
index 0000000..590a20d
--- /dev/null
+++ b/arch/ia64/include/asm/gpio.h
@@ -0,0 +1,55 @@
+/*
+ * Generic GPIO API implementation for IA-64.
+ *
+ * A stright copy of that for PowerPC which was:
+ *
+ * Copyright (c) 2007-2008  MontaVista Software, Inc.
+ *
+ * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ASM_IA64_GPIO_H
+#define _ASM_IA64_GPIO_H
+
+#include <linux/errno.h>
+#include <asm-generic/gpio.h>
+
+#ifdef CONFIG_GPIOLIB
+
+/*
+ * We don't (yet) implement inlined/rapid versions for on-chip gpios.
+ * Just call gpiolib.
+ */
+static inline int gpio_get_value(unsigned int gpio)
+{
+	return __gpio_get_value(gpio);
+}
+
+static inline void gpio_set_value(unsigned int gpio, int value)
+{
+	__gpio_set_value(gpio, value);
+}
+
+static inline int gpio_cansleep(unsigned int gpio)
+{
+	return __gpio_cansleep(gpio);
+}
+
+static inline int gpio_to_irq(unsigned int gpio)
+{
+	return __gpio_to_irq(gpio);
+}
+
+static inline int irq_to_gpio(unsigned int irq)
+{
+	return -EINVAL;
+}
+
+#endif /* CONFIG_GPIOLIB */
+
+#endif /* _ASM_IA64_GPIO_H */
-- 
1.7.5.3

