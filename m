From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 11 Feb 2004 01:05:46 +0000
Subject: [patch] 2.4.25-rc1 Remove generated files include/asm-ia64/offsets.h, drivers/ieee1394/oui.c
Message-Id: <2366.1076461546@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org

Some generated files are not being removed by make clean/mrproper.

include/asm-ia64/offsets.h is built by 'make dep' so must be removed by
'make mrproper', otherwise 'make dep clean' fails.

drivers/ieee1394/oui.c is just a normal 'make clean'.

Index: 25-rc1.1/arch/ia64/tools/Makefile
--- 25-rc1.1/arch/ia64/tools/Makefile Thu, 11 Dec 2003 12:05:21 +1100 kaos (linux-2.4/q/c/1_Makefile 1.1.2.1.1.1.1.1 644)
+++ 25-rc1.1(w)/arch/ia64/tools/Makefile Wed, 11 Feb 2004 11:56:00 +1100 kaos (linux-2.4/q/c/1_Makefile 1.1.2.1.1.1.1.1 644)
@@ -5,6 +5,7 @@ TARGET	= $(TOPDIR)/include/asm-ia64/offs
 all:
 
 mrproper: clean
+	rm -f $(TARGET)
 
 clean:
 	rm -f print_offsets.s print_offsets offsets.h
Index: 25-rc1.1/Makefile
--- 25-rc1.1/Makefile Fri, 06 Feb 2004 11:02:43 +1100 kaos (linux-2.4/T/c/50_Makefile 1.1.2.15.1.2.2.25.2.2.1.17.1.4.1.29.1.40.1.72.1.28 644)
+++ 25-rc1.1(w)/Makefile Wed, 11 Feb 2004 11:54:22 +1100 kaos (linux-2.4/T/c/50_Makefile 1.1.2.15.1.2.2.25.2.2.1.17.1.4.1.29.1.40.1.72.1.28 644)
@@ -223,7 +223,8 @@ CLEAN_FILES = \
 	drivers/tc/lk201-map.c \
 	net/khttpd/make_times_h \
 	net/khttpd/times.h \
-	submenu*
+	submenu* \
+	drivers/ieee1394/oui.c
 # directories removed with 'make clean'
 CLEAN_DIRS = \
 	modules

