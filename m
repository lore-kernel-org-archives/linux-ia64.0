From: Frans Pop <elendil@planet.nl>
Date: Thu, 23 Jul 2009 18:56:50 +0000
Subject: [PATCH] ia64: minor Makefile simplification through use of cc-ifversion
Message-Id: <200907232056.51064.elendil@planet.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
---

Change was suggested by Sam Ravnborg; see http://lkml.org/lkml/2009/7/18/15.
Untested.

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 58a7e46..2bf6107 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -41,10 +41,8 @@ $(error Sorry, you need a newer version of the assember, one that is built from
 		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
 endif
 
-ifeq ($(call cc-version),0304)
-	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
-	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
-endif
+cflags-$(CONFIG_ITANIUM)  += $(call cc-ifversion, -eq, 0304, -mtune=merced)
+cflags-$(CONFIG_MCKINLEY) += $(call cc-ifversion, -eq, 0304, -mtune=mckinley)
 
 KBUILD_CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
