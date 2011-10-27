From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 27 Oct 2011 13:01:43 +0000
Subject: [PATCH] asm-generic/gpio.h: merge basic gpiolib wrappers
Message-Id: <1319720503-3183-1-git-send-email-vapier@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1319528012-19006-1-git-send-email-broonie@opensource.wolfsonmicro.com>
In-Reply-To: <1319528012-19006-1-git-send-email-broonie@opensource.wolfsonmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely@secretlab.ca>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Haavard Skinnemoen <hskin>
Cc: linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, linux@lists.openrisc.net, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-dist-devel@blackfin.uclinux.org, linux-kernel@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>, linux-m68k@lists.linux-m68k.org

Rather than requiring architectures that use gpiolib but don't have
any need to define anything custom to copy an asm/gpio.h, merge this
code into the asm-generic/gpio.h.  We add ifdef checks so that arches
can still override things while using the asm-generic/gpio.h, but on
a more fine grained per-func approach.

I've compile tested these guys (with & without GPIOLIB), but don't
have the hardware to boot:
	- alpha defconfig
	- arm defconfig
	- blackfin defconfig
	- ia64 defconfig
	- mips: ar7 & ath79 & bcm47xx & bcm63xx & ip22 defconfig
	- powerpc: mpc85xx & ppc64 defconfig
	- sh: kfr2r09 defconfig
	- sparc defconfig
	- x86_64 defconfig

I don't have any toolchains for avr32, microblaze, openrisc, unicore32,
or xtensa.  So they lose :x.

I don't see m68k supporting gpoilib, so I've just ignored it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 arch/alpha/include/asm/Kbuild                   |    2 +
 arch/alpha/include/asm/gpio.h                   |   55 -------------------
 arch/arm/include/asm/gpio.h                     |   13 +++--
 arch/avr32/mach-at32ap/include/mach/gpio.h      |   19 +------
 arch/blackfin/include/asm/gpio.h                |   16 ++----
 arch/ia64/include/asm/Kbuild                    |    2 +
 arch/ia64/include/asm/gpio.h                    |   55 -------------------
 arch/microblaze/include/asm/Kbuild              |    2 +
 arch/microblaze/include/asm/gpio.h              |   53 ------------------
 arch/mips/include/asm/mach-ar7/gpio.h           |    5 --
 arch/mips/include/asm/mach-ath79/gpio.h         |    8 ++-
 arch/mips/include/asm/mach-bcm47xx/gpio.h       |    3 +
 arch/mips/include/asm/mach-bcm63xx/gpio.h       |    5 --
 arch/mips/include/asm/mach-generic/gpio.h       |    8 +--
 arch/mips/include/asm/mach-loongson/gpio.h      |    7 +--
 arch/mips/include/asm/mach-rc32434/gpio.h       |   10 +---
 arch/mips/include/asm/pmc-sierra/msp71xx/gpio.h |   12 +---
 arch/openrisc/include/asm/Kbuild                |    1 +
 arch/openrisc/include/asm/gpio.h                |   65 -----------------------
 arch/powerpc/include/asm/Kbuild                 |    2 +
 arch/powerpc/include/asm/gpio.h                 |   53 ------------------
 arch/sh/include/asm/gpio.h                      |   32 +-----------
 arch/sparc/include/asm/Kbuild                   |    1 +
 arch/sparc/include/asm/gpio.h                   |   36 -------------
 arch/unicore32/include/asm/gpio.h               |    8 ++-
 arch/x86/include/asm/Kbuild                     |    2 +
 arch/x86/include/asm/gpio.h                     |   53 ------------------
 arch/xtensa/include/asm/Kbuild                  |    2 +
 arch/xtensa/include/asm/gpio.h                  |   56 -------------------
 include/asm-generic/gpio.h                      |   23 ++++++++
 30 files changed, 81 insertions(+), 528 deletions(-)
 delete mode 100644 arch/alpha/include/asm/gpio.h
 delete mode 100644 arch/ia64/include/asm/gpio.h
 delete mode 100644 arch/microblaze/include/asm/gpio.h
 delete mode 100644 arch/openrisc/include/asm/gpio.h
 delete mode 100644 arch/powerpc/include/asm/gpio.h
 delete mode 100644 arch/sparc/include/asm/gpio.h
 delete mode 100644 arch/x86/include/asm/gpio.h
 delete mode 100644 arch/xtensa/include/asm/gpio.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index e423def..0bcff1a 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -1,5 +1,7 @@
 include include/asm-generic/Kbuild.asm
 
+generic-y += gpio.h
+
 header-y += compiler.h
 header-y += console.h
 header-y += fpu.h
diff --git a/arch/alpha/include/asm/gpio.h b/arch/alpha/include/asm/gpio.h
deleted file mode 100644
index 7dc6a63..0000000
--- a/arch/alpha/include/asm/gpio.h
+++ /dev/null
@@ -1,55 +0,0 @@
-/*
- * Generic GPIO API implementation for Alpha.
- *
- * A stright copy of that for PowerPC which was:
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _ASM_ALPHA_GPIO_H
-#define _ASM_ALPHA_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * We don't (yet) implement inlined/rapid versions for on-chip gpios.
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* _ASM_ALPHA_GPIO_H */
diff --git a/arch/arm/include/asm/gpio.h b/arch/arm/include/asm/gpio.h
index 11ad0bf..741efb2 100644
--- a/arch/arm/include/asm/gpio.h
+++ b/arch/arm/include/asm/gpio.h
@@ -5,14 +5,15 @@
 #include <mach/gpio.h>
 
 #ifndef __ARM_GPIOLIB_COMPLEX
+/* assume the mach has defined this */
+#ifndef irq_to_gpio
+#define irq_to_gpio irq_to_gpio
+#endif
+
 /* Note: this may rely upon the value of ARCH_NR_GPIOS set in mach/gpio.h */
 #include <asm-generic/gpio.h>
 
-/* The trivial gpiolib dispatchers */
-#define gpio_get_value  __gpio_get_value
-#define gpio_set_value  __gpio_set_value
-#define gpio_cansleep   __gpio_cansleep
-#endif
+#else
 
 /*
  * Provide a default gpio_to_irq() which should satisfy every case.
@@ -23,4 +24,6 @@
 #define gpio_to_irq	__gpio_to_irq
 #endif
 
+#endif
+
 #endif /* _ARCH_ARM_GPIO_H */
diff --git a/arch/avr32/mach-at32ap/include/mach/gpio.h b/arch/avr32/mach-at32ap/include/mach/gpio.h
index 0180f58..f2ff962 100644
--- a/arch/avr32/mach-at32ap/include/mach/gpio.h
+++ b/arch/avr32/mach-at32ap/include/mach/gpio.h
@@ -10,26 +10,13 @@
  */
 #define ARCH_NR_GPIOS	(NR_GPIO_IRQS + 2 * 32)
 
+/* We implement a few ourself */
+#define gpio_to_irq gpio_to_irq
+#define irq_to_gpio irq_to_gpio
 
 /* Arch-neutral GPIO API, supporting both "native" and external GPIOs. */
 #include <asm-generic/gpio.h>
 
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-
 static inline int gpio_to_irq(unsigned int gpio)
 {
 	if (gpio < NR_GPIO_IRQS)
diff --git a/arch/blackfin/include/asm/gpio.h b/arch/blackfin/include/asm/gpio.h
index 5a25856..6e25dcc 100644
--- a/arch/blackfin/include/asm/gpio.h
+++ b/arch/blackfin/include/asm/gpio.h
@@ -189,6 +189,12 @@ void bfin_gpio_set_value(unsigned gpio, int value);
 #include <asm/errno.h>
 
 #ifdef CONFIG_GPIOLIB
+
+/* We implement a few ourself */
+#define gpio_get_value gpio_get_value
+#define gpio_set_value gpio_set_value
+#define irq_to_gpio irq_to_gpio
+
 #include <asm-generic/gpio.h>		/* cansleep wrappers */
 
 static inline int gpio_get_value(unsigned int gpio)
@@ -207,16 +213,6 @@ static inline void gpio_set_value(unsigned int gpio, int value)
 		__gpio_set_value(gpio, value);
 }
 
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
 #else /* !CONFIG_GPIOLIB */
 
 static inline int gpio_request(unsigned gpio, const char *label)
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 241d1c5..d0fdd2d 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,5 +1,7 @@
 include include/asm-generic/Kbuild.asm
 
+generic-y += gpio.h
+
 header-y += break.h
 header-y += fpu.h
 header-y += gcc_intrin.h
diff --git a/arch/ia64/include/asm/gpio.h b/arch/ia64/include/asm/gpio.h
deleted file mode 100644
index 590a20d..0000000
--- a/arch/ia64/include/asm/gpio.h
+++ /dev/null
@@ -1,55 +0,0 @@
-/*
- * Generic GPIO API implementation for IA-64.
- *
- * A stright copy of that for PowerPC which was:
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _ASM_IA64_GPIO_H
-#define _ASM_IA64_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * We don't (yet) implement inlined/rapid versions for on-chip gpios.
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* _ASM_IA64_GPIO_H */
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index db5294c..5bf1ca7 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -1,3 +1,5 @@
 include include/asm-generic/Kbuild.asm
 
+generic-y += gpio.h
+
 header-y  += elf.h
diff --git a/arch/microblaze/include/asm/gpio.h b/arch/microblaze/include/asm/gpio.h
deleted file mode 100644
index 2b2c18b..0000000
--- a/arch/microblaze/include/asm/gpio.h
+++ /dev/null
@@ -1,53 +0,0 @@
-/*
- * Generic GPIO API implementation for PowerPC.
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _ASM_MICROBLAZE_GPIO_H
-#define _ASM_MICROBLAZE_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * We don't (yet) implement inlined/rapid versions for on-chip gpios.
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* _ASM_MICROBLAZE_GPIO_H */
diff --git a/arch/mips/include/asm/mach-ar7/gpio.h b/arch/mips/include/asm/mach-ar7/gpio.h
index c177cd1..78f40c2 100644
--- a/arch/mips/include/asm/mach-ar7/gpio.h
+++ b/arch/mips/include/asm/mach-ar7/gpio.h
@@ -27,11 +27,6 @@
 
 #define gpio_to_irq(gpio)	-1
 
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-
 /* Board specific GPIO functions */
 int ar7_gpio_enable(unsigned gpio);
 int ar7_gpio_disable(unsigned gpio);
diff --git a/arch/mips/include/asm/mach-ath79/gpio.h b/arch/mips/include/asm/mach-ath79/gpio.h
index 60dcb62..2c570a0 100644
--- a/arch/mips/include/asm/mach-ath79/gpio.h
+++ b/arch/mips/include/asm/mach-ath79/gpio.h
@@ -13,6 +13,12 @@
 #ifndef __ASM_MACH_ATH79_GPIO_H
 #define __ASM_MACH_ATH79_GPIO_H
 
+/* We implement a few ourself */
+#define gpio_get_value gpio_get_value
+#define gpio_set_value gpio_set_value
+#define gpio_to_irq gpio_to_irq
+#define irq_to_gpio irq_to_gpio
+
 #define ARCH_NR_GPIOS	64
 #include <asm-generic/gpio.h>
 
@@ -21,6 +27,4 @@ int irq_to_gpio(unsigned irq);
 int gpio_get_value(unsigned gpio);
 void gpio_set_value(unsigned gpio, int value);
 
-#define gpio_cansleep	__gpio_cansleep
-
 #endif /* __ASM_MACH_ATH79_GPIO_H */
diff --git a/arch/mips/include/asm/mach-bcm47xx/gpio.h b/arch/mips/include/asm/mach-bcm47xx/gpio.h
index 76961ca..d678316 100644
--- a/arch/mips/include/asm/mach-bcm47xx/gpio.h
+++ b/arch/mips/include/asm/mach-bcm47xx/gpio.h
@@ -19,6 +19,7 @@
 extern int gpio_request(unsigned gpio, const char *label);
 extern void gpio_free(unsigned gpio);
 extern int gpio_to_irq(unsigned gpio);
+#define gpio_to_irq gpio_to_irq
 
 static inline int gpio_get_value(unsigned gpio)
 {
@@ -35,6 +36,7 @@ static inline int gpio_get_value(unsigned gpio)
 	}
 	return -EINVAL;
 }
+#define gpio_get_value gpio_get_value
 
 static inline void gpio_set_value(unsigned gpio, int value)
 {
@@ -53,6 +55,7 @@ static inline void gpio_set_value(unsigned gpio, int value)
 #endif
 	}
 }
+#define gpio_set_value gpio_set_value
 
 static inline int gpio_direction_input(unsigned gpio)
 {
diff --git a/arch/mips/include/asm/mach-bcm63xx/gpio.h b/arch/mips/include/asm/mach-bcm63xx/gpio.h
index 1eb534d..c71bf66 100644
--- a/arch/mips/include/asm/mach-bcm63xx/gpio.h
+++ b/arch/mips/include/asm/mach-bcm63xx/gpio.h
@@ -5,11 +5,6 @@
 
 #define gpio_to_irq(gpio)	-1
 
-#define gpio_get_value __gpio_get_value
-#define gpio_set_value __gpio_set_value
-
-#define gpio_cansleep __gpio_cansleep
-
 #include <asm-generic/gpio.h>
 
 #endif /* __ASM_MIPS_MACH_BCM63XX_GPIO_H */
diff --git a/arch/mips/include/asm/mach-generic/gpio.h b/arch/mips/include/asm/mach-generic/gpio.h
index b4e7020..e8a89c5 100644
--- a/arch/mips/include/asm/mach-generic/gpio.h
+++ b/arch/mips/include/asm/mach-generic/gpio.h
@@ -1,11 +1,7 @@
 #ifndef __ASM_MACH_GENERIC_GPIO_H
 #define __ASM_MACH_GENERIC_GPIO_H
 
-#ifdef CONFIG_GPIOLIB
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-#else
+#ifndef CONFIG_GPIOLIB
 int gpio_request(unsigned gpio, const char *label);
 void gpio_free(unsigned gpio);
 int gpio_direction_input(unsigned gpio);
@@ -14,7 +10,9 @@ int gpio_get_value(unsigned gpio);
 void gpio_set_value(unsigned gpio, int value);
 #endif
 int gpio_to_irq(unsigned gpio);
+#define gpio_to_irq gpio_to_irq
 int irq_to_gpio(unsigned irq);
+#define irq_to_gpio irq_to_gpio
 
 #include <asm-generic/gpio.h>		/* cansleep wrappers */
 
diff --git a/arch/mips/include/asm/mach-loongson/gpio.h b/arch/mips/include/asm/mach-loongson/gpio.h
index e30e73d..df6efc0 100644
--- a/arch/mips/include/asm/mach-loongson/gpio.h
+++ b/arch/mips/include/asm/mach-loongson/gpio.h
@@ -13,6 +13,8 @@
 #ifndef	__STLS2F_GPIO_H
 #define	__STLS2F_GPIO_H
 
+#define gpio_to_irq gpio_to_irq
+
 #include <asm-generic/gpio.h>
 
 extern void gpio_set_value(unsigned gpio, int value);
@@ -27,9 +29,4 @@ static inline int gpio_to_irq(int gpio)
 	return -EINVAL;
 }
 
-static inline int irq_to_gpio(int gpio)
-{
-	return -EINVAL;
-}
-
 #endif				/* __STLS2F_GPIO_H */
diff --git a/arch/mips/include/asm/mach-rc32434/gpio.h b/arch/mips/include/asm/mach-rc32434/gpio.h
index 12ee8d5..8b0815b 100644
--- a/arch/mips/include/asm/mach-rc32434/gpio.h
+++ b/arch/mips/include/asm/mach-rc32434/gpio.h
@@ -13,18 +13,14 @@
 #ifndef _RC32434_GPIO_H_
 #define _RC32434_GPIO_H_
 
+#define gpio_to_irq(gpio)	(8 + 4 * 32 + gpio)
+#define irq_to_gpio(irq)	(irq - (8 + 4 * 32))
+
 #include <linux/types.h>
 #include <asm-generic/gpio.h>
 
 #define NR_BUILTIN_GPIO		32
 
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-
-#define gpio_to_irq(gpio)	(8 + 4 * 32 + gpio)
-#define irq_to_gpio(irq)	(irq - (8 + 4 * 32))
-
 struct rb532_gpio_reg {
 	u32   gpiofunc;   /* GPIO Function Register
 			   * gpiofunc[x]=0 bit = gpio
diff --git a/arch/mips/include/asm/pmc-sierra/msp71xx/gpio.h b/arch/mips/include/asm/pmc-sierra/msp71xx/gpio.h
index ebdbab9..8356a8e 100644
--- a/arch/mips/include/asm/pmc-sierra/msp71xx/gpio.h
+++ b/arch/mips/include/asm/pmc-sierra/msp71xx/gpio.h
@@ -11,16 +11,15 @@
 #ifndef __PMC_MSP71XX_GPIO_H
 #define __PMC_MSP71XX_GPIO_H
 
+/* We implement a few ourself */
+#define gpio_to_irq gpio_to_irq
+
 /* Max number of gpio's is 28 on chip plus 3 banks of I2C IO Expanders */
 #define ARCH_NR_GPIOS (28 + (3 * 8))
 
 /* new generic GPIO API - see Documentation/gpio.txt */
 #include <asm-generic/gpio.h>
 
-#define gpio_get_value	__gpio_get_value
-#define gpio_set_value	__gpio_set_value
-#define gpio_cansleep	__gpio_cansleep
-
 /* Setup calls for the gpio and gpio extended */
 extern void msp71xx_init_gpio(void);
 extern void msp71xx_init_gpio_extended(void);
@@ -38,9 +37,4 @@ static inline int gpio_to_irq(unsigned gpio)
 	return -EINVAL;
 }
 
-static inline int irq_to_gpio(unsigned irq)
-{
-	return -EINVAL;
-}
-
 #endif /* __PMC_MSP71XX_GPIO_H */
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 11162e6..03f0823 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -23,6 +23,7 @@ generic-y += fb.h
 generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += futex.h
+generic-y += gpio.h
 generic-y += hardirq.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
diff --git a/arch/openrisc/include/asm/gpio.h b/arch/openrisc/include/asm/gpio.h
deleted file mode 100644
index 0b0d174..0000000
--- a/arch/openrisc/include/asm/gpio.h
+++ /dev/null
@@ -1,65 +0,0 @@
-/*
- * OpenRISC Linux
- *
- * Linux architectural port borrowing liberally from similar works of
- * others.  All original copyrights apply as per the original source
- * declaration.
- *
- * OpenRISC implementation:
- * Copyright (C) 2003 Matjaz Breskvar <phoenix@bsemi.com>
- * Copyright (C) 2010-2011 Jonas Bonn <jonas@southpole.se>
- * et al.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef __ASM_OPENRISC_GPIO_H
-#define __ASM_OPENRISC_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * OpenRISC (or1k) does not have on-chip GPIO's so there is not really
- * any standardized implementation that makes sense here.  If passing
- * through gpiolib becomes a bottleneck then it may make sense, on a
- * case-by-case basis, to implement these inlined/rapid versions.
- *
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-/*
- * Not implemented, yet.
- */
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return -ENOSYS;
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* __ASM_OPENRISC_GPIO_H */
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index d51df17..9cf0632 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -1,5 +1,7 @@
 include include/asm-generic/Kbuild.asm
 
+generic-y += gpio.h
+
 header-y += auxvec.h
 header-y += bootx.h
 header-y += byteorder.h
diff --git a/arch/powerpc/include/asm/gpio.h b/arch/powerpc/include/asm/gpio.h
deleted file mode 100644
index 38762ed..0000000
--- a/arch/powerpc/include/asm/gpio.h
+++ /dev/null
@@ -1,53 +0,0 @@
-/*
- * Generic GPIO API implementation for PowerPC.
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef __ASM_POWERPC_GPIO_H
-#define __ASM_POWERPC_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * We don't (yet) implement inlined/rapid versions for on-chip gpios.
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* __ASM_POWERPC_GPIO_H */
diff --git a/arch/sh/include/asm/gpio.h b/arch/sh/include/asm/gpio.h
index 04f53d3..44fee05 100644
--- a/arch/sh/include/asm/gpio.h
+++ b/arch/sh/include/asm/gpio.h
@@ -12,9 +12,6 @@
 #ifndef __ASM_SH_GPIO_H
 #define __ASM_SH_GPIO_H
 
-#include <linux/kernel.h>
-#include <linux/errno.h>
-
 #if defined(CONFIG_CPU_SH3)
 #include <cpu/gpio.h>
 #endif
@@ -22,33 +19,6 @@
 #define ARCH_NR_GPIOS 512
 #include <linux/sh_pfc.h>
 
-#ifdef CONFIG_GPIOLIB
-
-static inline int gpio_get_value(unsigned gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -ENOSYS;
-}
-
-#endif /* CONFIG_GPIOLIB */
+#include <asm-generic/gpio.h>
 
 #endif /* __ASM_SH_GPIO_H */
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 2c2e388..6d27595 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -18,6 +18,7 @@ header-y += utrap.h
 header-y += watchdog.h
 
 generic-y += div64.h
+generic-y += gpio.h
 generic-y += local64.h
 generic-y += irq_regs.h
 generic-y += local.h
diff --git a/arch/sparc/include/asm/gpio.h b/arch/sparc/include/asm/gpio.h
deleted file mode 100644
index a0e3ac0..0000000
--- a/arch/sparc/include/asm/gpio.h
+++ /dev/null
@@ -1,36 +0,0 @@
-#ifndef __ASM_SPARC_GPIO_H
-#define __ASM_SPARC_GPIO_H
-
-#include <linux/errno.h>
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return -ENOSYS;
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* __ASM_SPARC_GPIO_H */
diff --git a/arch/unicore32/include/asm/gpio.h b/arch/unicore32/include/asm/gpio.h
index 2716f14..437f4e8 100644
--- a/arch/unicore32/include/asm/gpio.h
+++ b/arch/unicore32/include/asm/gpio.h
@@ -13,6 +13,12 @@
 #ifndef __UNICORE_GPIO_H__
 #define __UNICORE_GPIO_H__
 
+/* We implement a few ourself */
+#define gpio_get_value gpio_get_value
+#define gpio_set_value gpio_set_value
+#define gpio_to_irq gpio_to_irq
+#define irq_to_gpio irq_to_gpio
+
 #include <linux/io.h>
 #include <asm/irq.h>
 #include <mach/hardware.h>
@@ -83,8 +89,6 @@ static inline void gpio_set_value(unsigned gpio, int value)
 		__gpio_set_value(gpio, value);
 }
 
-#define gpio_cansleep	__gpio_cansleep
-
 static inline unsigned gpio_to_irq(unsigned gpio)
 {
 	if ((gpio < IRQ_GPIOHIGH) && (FIELD(1, 1, gpio) & readl(GPIO_GPIR)))
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 6fa90a8..99d44ce 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -1,5 +1,7 @@
 include include/asm-generic/Kbuild.asm
 
+generic-y += gpio.h
+
 header-y += boot.h
 header-y += bootparam.h
 header-y += debugreg.h
diff --git a/arch/x86/include/asm/gpio.h b/arch/x86/include/asm/gpio.h
deleted file mode 100644
index 91d915a..0000000
--- a/arch/x86/include/asm/gpio.h
+++ /dev/null
@@ -1,53 +0,0 @@
-/*
- * Generic GPIO API implementation for x86.
- *
- * Derived from the generic GPIO API for powerpc:
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _ASM_X86_GPIO_H
-#define _ASM_X86_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* _ASM_X86_GPIO_H */
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index c68e168..7d52c50 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -1 +1,3 @@
 include include/asm-generic/Kbuild.asm
+
+generic-y += gpio.h
diff --git a/arch/xtensa/include/asm/gpio.h b/arch/xtensa/include/asm/gpio.h
deleted file mode 100644
index a8c9fc4..0000000
--- a/arch/xtensa/include/asm/gpio.h
+++ /dev/null
@@ -1,56 +0,0 @@
-/*
- * Generic GPIO API implementation for xtensa.
- *
- * Stolen from x86, which is derived from the generic GPIO API for powerpc:
- *
- * Copyright (c) 2007-2008  MontaVista Software, Inc.
- *
- * Author: Anton Vorontsov <avorontsov@ru.mvista.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _ASM_XTENSA_GPIO_H
-#define _ASM_XTENSA_GPIO_H
-
-#include <asm-generic/gpio.h>
-
-#ifdef CONFIG_GPIOLIB
-
-/*
- * Just call gpiolib.
- */
-static inline int gpio_get_value(unsigned int gpio)
-{
-	return __gpio_get_value(gpio);
-}
-
-static inline void gpio_set_value(unsigned int gpio, int value)
-{
-	__gpio_set_value(gpio, value);
-}
-
-static inline int gpio_cansleep(unsigned int gpio)
-{
-	return __gpio_cansleep(gpio);
-}
-
-static inline int gpio_to_irq(unsigned int gpio)
-{
-	return __gpio_to_irq(gpio);
-}
-
-/*
- * Not implemented, yet.
- */
-static inline int irq_to_gpio(unsigned int irq)
-{
-	return -EINVAL;
-}
-
-#endif /* CONFIG_GPIOLIB */
-
-#endif /* _ASM_XTENSA_GPIO_H */
diff --git a/include/asm-generic/gpio.h b/include/asm-generic/gpio.h
index d494001..622851c 100644
--- a/include/asm-generic/gpio.h
+++ b/include/asm-generic/gpio.h
@@ -170,6 +170,29 @@ extern int __gpio_cansleep(unsigned gpio);
 
 extern int __gpio_to_irq(unsigned gpio);
 
+#ifndef gpio_get_value
+#define gpio_get_value(gpio) __gpio_get_value(gpio)
+#endif
+
+#ifndef gpio_set_value
+#define gpio_set_value(gpio, value) __gpio_set_value(gpio, value)
+#endif
+
+#ifndef gpio_cansleep
+#define gpio_cansleep(gpio) __gpio_cansleep(gpio)
+#endif
+
+#ifndef gpio_to_irq
+#define gpio_to_irq(gpio) __gpio_to_irq(gpio)
+#endif
+
+#ifndef irq_to_gpio
+static inline int irq_to_gpio(unsigned int irq)
+{
+	return -EINVAL;
+}
+#endif
+
 /**
  * struct gpio - a structure describing a GPIO with configuration
  * @gpio:	the GPIO number
-- 
1.7.6.1

