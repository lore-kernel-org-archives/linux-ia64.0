From: Pat Gefre <pfg@sgi.com>
Date: Mon, 08 Mar 2004 23:20:16 +0000
Subject: Re: [2.6 PATCH] Altix - console driver calls console_initcall
Message-Id: <200403082320.i28NKGsk066877@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403082032.i28KWvuw082582@fsgi900.americas.sgi.com>
In-Reply-To: <200403082032.i28KWvuw082582@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bjorn.helgaas@hp.com, davidm@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> On Monday 08 March 2004 1:32 pm, Pat Gefre wrote:
> > -static void __init sn_sal_serial_console_init(void);
> > +int __init sn_sal_serial_console_init(void);
> 
> I don't see any callers other than the console_initcall(), so
> you could lose the declaration altogether.
> 
> > -static void __init
> > +int __init
> >  sn_sal_serial_console_init(void)
> 
> console_initcall() works fine with static functions, so you should
> be able to keep this static.
> 
> Bjorn

You're right.....

Here's a new mod which goes against 1.1698 too (the 'staircase' mod) -
so it'll have the correct line numbers - in other words it'll apply
cleanly if 1.1698 has already been applied.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1693  -> 1.1694 
#	drivers/char/sn_serial.c	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/08	pfg@sgi.com	1.1694
# drivers/char/sn_serial.c
#     Make console_initcall() for proper registration.
# --------------------------------------------
#
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Mon Mar  8 17:15:51 2004
+++ b/drivers/char/sn_serial.c	Mon Mar  8 17:15:51 2004
@@ -105,7 +105,6 @@
 static struct sn_sal_ops *sn_func;
 
 /* Prototypes */
-static void __init sn_sal_serial_console_init(void);
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
 
@@ -1015,7 +1011,7 @@
 	.index = -1
 };
 
-static void __init
+static int __init
 sn_sal_serial_console_init(void)
 {
 	if (ia64_platform_is("sn2")) {
@@ -1023,6 +1019,8 @@
 		sn_debug_printf("sn_sal_serial_console_init : register console\n");
 		register_console(&sal_console);
 	}
+	return 0;
 }
+console_initcall(sn_sal_serial_console_init);
 
 #endif /* CONFIG_SGI_L1_SERIAL_CONSOLE */
