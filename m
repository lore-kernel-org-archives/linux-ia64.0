From: Tigran Aivazian <tigran@veritas.com>
Date: Thu, 09 Dec 2004 23:24:05 +0000
Subject: [patch-2.6.x] fix for make clean and make mrproper
Message-Id: <Pine.LNX.4.61.0412092320460.6269@ezer.homenet>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hello,

On IA64 architecture the "make clean" does not correspond to its 
definition:

# make clean     Delete most generated files
#                Leave enough to build external modules

because it deletes include/asm-ia64/offsets.h file which can easily be 
included by a module, e.g. via this header path:

In file included from include/linux/thread_info.h:21,
                  from include/linux/spinlock.h:12,
                  from include/linux/capability.h:45,
                  from include/linux/sched.h:7,
                  from include/asm/uaccess.h:37,

So the fix is to remove this file from CLEAN_FILES and add it to 
MRPROPER_FILES, so that it is NOT removed by "make clean" and removed by 
"make mrproper". The patch is enclosed.

Kind regards
Tigran

--- arch/ia64/Makefile.0	2004-12-08 23:19:44.429993868 +0000
+++ arch/ia64/Makefile	2004-12-08 23:18:57.238588196 +0000
@@ -87,7 +87,9 @@
  archclean:
  	$(Q)$(MAKE) $(clean)=$(boot)

-CLEAN_FILES += include/asm-ia64/.offsets.h.stamp include/asm-ia64/offsets.h vmlinux.gz bootloader
+CLEAN_FILES += include/asm-ia64/.offsets.h.stamp vmlinux.gz bootloader
+
+MRPROPER_FILES += include/asm-ia64/offsets.h

  prepare: include/asm-ia64/offsets.h

