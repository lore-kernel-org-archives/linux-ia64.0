From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 06:17:04 +0000
Subject: Re: anyone using Itanium B-step support?
Message-Id: <16889.55520.934628.71280@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
In-Reply-To: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Jan 2005 18:32:49 -0800, James E Wilson <wilson@tuliptree.org> said:

  >> I would have done it myself but there was no "Signed-off-by"
  >> trailer in your patch so I think you may need to resend the patch
  >> anyhow

  James> I know nothing about submitting linux kernel patches.  My
  James> patch is completely untested, by the way, as I doubt that I
  James> can build a working kernel without help.  It was more a
  James> suggestion than an actual patch.

Ah, OK, in that case, here is a (compile-)tested patch.

Tony, please apply.

	--david

ia64: Remove Merced B-step support

Remove left-over support for Merced B-step CPUs as suggested by Jim
Wilson.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/Kconfig 1.85 vs edited ==--- 1.85/arch/ia64/Kconfig	2005-01-24 13:41:13 -08:00
+++ edited/arch/ia64/Kconfig	2005-01-27 22:05:34 -08:00
@@ -158,14 +158,6 @@
 	depends on ITANIUM
 	default y
 
-config ITANIUM_BSTEP_SPECIFIC
-	bool "Itanium B-step specific code"
-	depends on ITANIUM
-	help
-	  Select this option to build a kernel for an Itanium prototype system
-	  with a B-step CPU.  You have a B-step CPU if the "revision" field in
-	  /proc/cpuinfo has a value in the range from 1 to 4.
-
 # align cache-sensitive data to 128 bytes
 config IA64_L1_CACHE_SHIFT
 	int
=== arch/ia64/Makefile 1.74 vs edited ==--- 1.74/arch/ia64/Makefile	2005-01-14 15:52:52 -08:00
+++ edited/arch/ia64/Makefile	2005-01-27 22:05:43 -08:00
@@ -46,8 +46,6 @@
 	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
 endif
 
-cflags-$(CONFIG_ITANIUM_BSTEP_SPECIFIC)	+= -mb-step
-
 CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
 
=== arch/ia64/configs/bigsur_defconfig 1.2 vs edited ==--- 1.2/arch/ia64/configs/bigsur_defconfig	2004-11-30 08:48:16 -08:00
+++ edited/arch/ia64/configs/bigsur_defconfig	2005-01-27 22:05:20 -08:00
@@ -73,7 +73,6 @@
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
 CONFIG_IA64_BRL_EMU=y
-# CONFIG_ITANIUM_BSTEP_SPECIFIC is not set
 CONFIG_IA64_L1_CACHE_SHIFT=6
 # CONFIG_NUMA is not set
 # CONFIG_VIRTUAL_MEM_MAP is not set
