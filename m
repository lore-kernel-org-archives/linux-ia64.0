From: Pat Gefre <pfg@sgi.com>
Date: Mon, 08 Mar 2004 20:32:56 +0000
Subject: [2.6 PATCH] Altix - console driver calls console_initcall
Message-Id: <200403082032.i28KWvuw082582@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Small mod to have the console driver call console_initcall() to
register.




# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1692  -> 1.1693 
#	drivers/char/sn_serial.c	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/08	pfg@sgi.com	1.1693
# drivers/char/sn_serial.c
#     Make console_initcall() for proper registration.
# --------------------------------------------
#
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Mon Mar  8 14:28:53 2004
+++ b/drivers/char/sn_serial.c	Mon Mar  8 14:28:53 2004
@@ -82,7 +82,6 @@
 static unsigned long sn_interrupt_timeout;
 
 extern u64 master_node_bedrock_address;
-
 static int sn_debug_printf(const char *fmt, ...);
 
 #undef DEBUG
@@ -105,7 +104,7 @@
 static struct sn_sal_ops *sn_func;
 
 /* Prototypes */
-static void __init sn_sal_serial_console_init(void);
+int __init sn_sal_serial_console_init(void);
 static int snt_hw_puts(const char *, int);
 static int snt_poll_getc(void);
 static int snt_poll_input_pending(void);
@@ -921,9 +920,6 @@
 		printk(KERN_ERR "sn_serial: Unable to register tty driver\n");
 		return retval;
 	}
-#ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
-	sn_sal_serial_console_init();
-#endif	/* CONFIG_SGI_L1_SERIAL_CONSOLE */
 	return 0;
 }
 
@@ -993,7 +989,7 @@
 	.index = -1
 };
 
-static void __init
+int __init
 sn_sal_serial_console_init(void)
 {
 	if (ia64_platform_is("sn2")) {
@@ -1001,6 +997,8 @@
 		sn_debug_printf("sn_sal_serial_console_init : register console\n");
 		register_console(&sal_console);
 	}
+	return 0;
 }
+console_initcall(sn_sal_serial_console_init);
 
 #endif /* CONFIG_SGI_L1_SERIAL_CONSOLE */
