From: Hirofumi Fujita <fujita@kanagawa.hitachi.co.jp>
Date: Wed, 08 Nov 2000 09:28:17 +0000
Subject: [Linux-ia64] test10 bug on SW IO TLB
Message-Id: <marc-linux-ia64-105590678205667@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

there seems to be a bug on software IO TLB buffer.

Kernel command line option `swiotlb=' is ignored
when the bounce buffer for SW IO TLB is allocated.

Following is a patch to this.
But the call to setup_swiotlb should be in some file in
arch/ia64/kernel/ , i guess.

--- linux-2.4.0-test10-ia64-001101/arch/ia64/kernel/setup.c.org	Tue Oct 10 09:54:55 2000
+++ linux-2.4.0-test10-ia64-001101/arch/ia64/kernel/setup.c	Wed Nov  8 18:00:29 2000
@@ -255,13 +255,6 @@
 
 	paging_init();
 	platform_setup(cmdline_p);
-
-#ifdef CONFIG_SWIOTLB
-	{
-		extern void setup_swiotlb (void);
-		setup_swiotlb();
-	}
-#endif
 }
 
 /*
--- linux-2.4.0-test10-ia64-001101/init/main.c.org	Thu Nov  2 20:52:13 2000
+++ linux-2.4.0-test10-ia64-001101/init/main.c	Wed Nov  8 18:01:09 2000
@@ -527,6 +527,12 @@
 	setup_arch(&command_line);
 	printk("Kernel command line: %s\n", saved_command_line);
 	parse_options(command_line);
+#ifdef CONFIG_SWIOTLB
+	{
+		extern void setup_swiotlb (void);
+		setup_swiotlb();
+	}
+#endif
 	trap_init();
 	init_IRQ();
 	sched_init();
----------------

Hirofumi Fujita
Hitachi, Ltd.

