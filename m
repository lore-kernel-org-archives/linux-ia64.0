From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 28 Jul 2006 14:01:55 +0000
Subject: [PATCH 2/2] Fix IA64 components
Message-Id: <20060728140155.9149.7093.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org
Cc: Prarit Bhargava <prarit@sgi.com>

Patch to fix export issue with RAID5 + IA64.

	-removes dead CONFIG options

This patch should be committed by the IA64 maintainer.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff -urNp linux-2.6.17.ia64.orig/arch/ia64/kernel/ia64_ksyms.c linux-2.6.17.ia64/arch/ia64/kernel/ia64_ksyms.c
--- linux-2.6.17.ia64.orig/arch/ia64/kernel/ia64_ksyms.c	2006-07-27 09:20:01.000000000 -0400
+++ linux-2.6.17.ia64/arch/ia64/kernel/ia64_ksyms.c	2006-07-27 14:51:42.000000000 -0400
@@ -67,7 +68,7 @@ EXPORT_SYMBOL(__udivdi3);
 EXPORT_SYMBOL(__moddi3);
 EXPORT_SYMBOL(__umoddi3);
 
-#if defined(CONFIG_MD_RAID5) || defined(CONFIG_MD_RAID5_MODULE)
+#ifdef CONFIG_MD_RAID5_IA64
 extern void xor_ia64_2(void);
 extern void xor_ia64_3(void);
 extern void xor_ia64_4(void);
diff -urNp linux-2.6.17.ia64.orig/arch/ia64/lib/Makefile linux-2.6.17.ia64/arch/ia64/lib/Makefile
--- linux-2.6.17.ia64.orig/arch/ia64/lib/Makefile	2006-07-27 09:20:01.000000000 -0400
+++ linux-2.6.17.ia64/arch/ia64/lib/Makefile	2006-07-27 14:51:19.000000000 -0400
@@ -14,7 +14,7 @@ lib-y := __divsi3.o __udivsi3.o __modsi3
 lib-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
 lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+= carta_random.o
-lib-$(CONFIG_MD_RAID5)	+= xor.o
+lib-$(CONFIG_MD_RAID5_IA64)	+= xor.o
 
 AFLAGS___divdi3.o	 AFLAGS___udivdi3.o	= -DUNSIGNED
