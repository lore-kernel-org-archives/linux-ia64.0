From: Gary Hade <garyhade@us.ibm.com>
Date: Tue, 02 Apr 2002 01:36:12 +0000
Subject: [Linux-ia64] arch/ia64/Makefile tweak
Message-Id: <marc-linux-ia64-105590701905357@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If the gcc in your PATH is version 2.X and you are not 
using cross tools (the CROSS_COMPILE make macro is null) 
`make CC=<path to a 3.X gcc>` fails due to the lack of
--param max-inline-insns 00 on the compile lines.

This happens because GCC_VERSION in arch/ia64/Makefile is 
determined using $(CROSS_COMPILE)$(HOSTCC) which expands 
"gcc" picking up gcc 2.X.  With GCC_VERSION defined as 2 the 
additional CFLAGS options within the ifneq ($(GCC_VERSION),2) 
are not being added.

You can work around the problem by also setting HOSTCC on the
make command line
  e.g. `make CC=<path to a 3.X gcc> HOSTCC=<path to a 3.X gcc>`
but I believe the correct solution is to use $(CC) instead of
$(CROSS_COMPILE)$(HOSTCC) to determine GCC_VERSION.

Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc


--- arch/ia64/Makefile.orig	Wed Mar 27 13:11:59 2002
+++ arch/ia64/Makefile	Mon Apr  1 15:26:14 2002
@@ -22,7 +22,7 @@
 # -ffunction-sections
 CFLAGS_KERNEL := -mconstant-gp
 
-GCC_VERSION=$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
+GCC_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 
 ifneq ($(GCC_VERSION),2)
 	CFLAGS += -frename-registers --param max-inline-insns 00


