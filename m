From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 14 Jun 2004 22:27:21 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <200406141627.21540.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 03 June 2004 3:49 pm, Jesse Barnes wrote:
> Allow consoles to be registered early if they support doing output very early 
> in the boot process.  Consoles that allow this are subject to the limitations 
> outlined in the comments for the early_console_setup routine.

(See original mail with patch here:
    http://www.gelato.unsw.edu.au/linux-ia64/0406/9894.html)

I'm still a little uneasy about setting cpu_online for CPU 0 so early.
What if somebody comes along in the future and assumes the original
semantics for cpu_online(0)?

As another possibility, the following is a little more intrusive to
printk.c, but also a little more explicit about what we're doing
(untested).

=== drivers/char/sn_serial.c 1.14 vs edited ==--- 1.14/drivers/char/sn_serial.c	2004-05-11 09:25:13 -06:00
+++ edited/drivers/char/sn_serial.c	2004-06-14 16:24:05 -06:00
@@ -1007,6 +1007,7 @@
 
 static struct console sal_console = {
 	.name = "ttyS",
+	.flags = CON_EARLY,
 	.write = sn_sal_console_write,
 	.device = sn_sal_console_device,
 	.setup = sn_sal_console_setup,
=== include/linux/console.h 1.13 vs edited ==--- 1.13/include/linux/console.h	2004-05-14 20:00:12 -06:00
+++ edited/include/linux/console.h	2004-06-14 12:42:16 -06:00
@@ -80,6 +80,7 @@
 #define CON_PRINTBUFFER	(1)
 #define CON_CONSDEV	(2) /* Last on the command line */
 #define CON_ENABLED	(4)
+#define CON_EARLY	(8) /* Works before CPU is online */
 
 struct console
 {
=== kernel/printk.c 1.38 vs edited ==--- 1.38/kernel/printk.c	2004-05-25 03:53:03 -06:00
+++ edited/kernel/printk.c	2004-06-14 16:12:17 -06:00
@@ -113,6 +113,9 @@
 /* Flag: console code may call schedule() */
 static int console_may_schedule;
 
+/* Early consoles work before CPU is online */
+static int early_console_registered;
+
 /*
  *	Setup a list of consoles. Called from init/main.c
  */
@@ -384,7 +387,8 @@
 	struct console *con;
 
 	for (con = console_drivers; con; con = con->next) {
-		if ((con->flags & CON_ENABLED) && con->write)
+		if ((con->flags & CON_ENABLED) && con->write &&
+		    (cpu_online(smp_processor_id()) || con->flags & CON_EARLY))
 			con->write(con, &LOG_BUF(start), end - start);
 	}
 }
@@ -544,7 +548,8 @@
 	}
 
 	if (!cpu_online(smp_processor_id()) &&
-	    system_state != SYSTEM_RUNNING) {
+	    system_state != SYSTEM_RUNNING &&
+	    !early_console_registered) {
 		/*
 		 * Some console drivers may assume that per-cpu resources have
 		 * been allocated.  So don't allow them to be called by this
@@ -733,6 +738,8 @@
 
 	if (!(console->flags & CON_ENABLED))
 		return;
+
+	early_console_registered |= console->flags & CON_EARLY;
 
 	/*
 	 *	Put this console in the list - keep the
