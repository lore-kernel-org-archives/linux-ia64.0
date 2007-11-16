From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Date: Fri, 16 Nov 2007 01:16:54 +0000
Subject: [PATCH] IA64:  Drop the unnecessary test for cc-version 0304.
Message-Id: <alpine.LFD.0.9999.0711152014490.1651@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Since the current build structure rejects any version of gcc < 3.2,
there's no point in testing for an even older version.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 34951aa..ff18c72 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -39,11 +39,6 @@ $(error Sorry, you need a newer version of the assember, one that is built from
 		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
 endif

-ifeq ($(call cc-version),0304)
-	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
-	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
-endif
-
 KBUILD_CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o

====================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
====================================
