From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:18:55 +0000
Subject: [PATCH] update arch/ia64/sn/kernel/sn2/Makefile
Message-Id: <marc-linux-ia64-106467235426573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ptc_deadlock.o sn2_smp.o only make sense for CONFIG_SMP,
sn_proc_fs.o prominfo_proc.o are procfs-only


diff -Nru a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
--- a/arch/ia64/sn/kernel/sn2/Makefile	Sat Sep 27 16:16:35 2003
+++ b/arch/ia64/sn/kernel/sn2/Makefile	Sat Sep 27 16:16:35 2003
@@ -11,5 +11,6 @@
 
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
-obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-	 prominfo_proc.o timer.o
+obj-y			+= cache.o io.o timer.o
+obj-$(CONFIG_SMP)	+= ptc_deadlock.o sn2_smp.o
+obj-$(CONFIG_PROC_FS)	+= sn_proc_fs.o prominfo_proc.o
diff -Nru a/arch/ia64/sn/kernel/sn2/sn_proc_fs.c b/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
--- a/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Sat Sep 27 16:16:35 2003
+++ b/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Sat Sep 27 16:16:35 2003
@@ -31,10 +31,8 @@
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
  */
 #include <linux/config.h>
-#include <asm/uaccess.h>
-
-#ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
+#include <asm/uaccess.h>
 #include <asm/sn/sn_sal.h>
 
 
@@ -191,5 +189,3 @@
 	register_sn_force_interrupt();
 	register_sn_linkstats();
 }
-
-#endif /* CONFIG_PROC_FS */
