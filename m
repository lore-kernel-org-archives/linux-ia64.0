From: Christoph Hellwig <hch@lst.de>
Date: Sat, 28 Feb 2004 11:35:08 +0000
Subject: [PATCH] simerial refcounting uptdate
Message-Id: <20040228113508.GA30270@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


--- 1.22/arch/ia64/hp/sim/simserial.c	Tue Jun 17 02:15:40 2003
+++ edited/arch/ia64/hp/sim/simserial.c	Sat Feb 28 13:35:09 2004
@@ -636,7 +636,6 @@
 #ifdef SIMSERIAL_DEBUG
 		printk("rs_close: hung_up\n");
 #endif
-		MOD_DEC_USE_COUNT;
 		local_irq_restore(flags);
 		return;
 	}
@@ -661,7 +660,6 @@
 		state->count = 0;
 	}
 	if (state->count) {
-		MOD_DEC_USE_COUNT;
 		local_irq_restore(flags);
 		return;
 	}
@@ -686,7 +684,6 @@
 	}
 	info->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
 	wake_up_interruptible(&info->close_wait);
-	MOD_DEC_USE_COUNT;
 }
 
 /*
@@ -874,17 +871,12 @@
 	int			retval, line;
 	unsigned long		page;
 
-	MOD_INC_USE_COUNT;
 	line = tty->index;
-	if ((line < 0) || (line >= NR_PORTS)) {
-		MOD_DEC_USE_COUNT;
+	if ((line < 0) || (line >= NR_PORTS))
 		return -ENODEV;
-	}
 	retval = get_async_struct(line, &info);
-	if (retval) {
-		MOD_DEC_USE_COUNT;
+	if (retval)
 		return retval;
-	}
 	tty->driver_data = info;
 	info->tty = tty;
 
@@ -895,10 +887,8 @@
 
 	if (!tmp_buf) {
 		page = get_zeroed_page(GFP_KERNEL);
-		if (!page) {
-			/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
+		if (!page)
 			return -ENOMEM;
-		}
 		if (tmp_buf)
 			free_page(page);
 		else
@@ -912,7 +902,6 @@
 	    (info->flags & ASYNC_CLOSING)) {
 		if (info->flags & ASYNC_CLOSING)
 			interruptible_sleep_on(&info->close_wait);
-		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
 #ifdef SERIAL_DO_RESTART
 		return ((info->flags & ASYNC_HUP_NOTIFY) ?
 			-EAGAIN : -ERESTARTSYS);
@@ -926,7 +915,6 @@
 	 */
 	retval = startup(info);
 	if (retval) {
-		/* MOD_DEC_USE_COUNT; "info->tty" will cause this? */
 		return retval;
 	}
 
@@ -1042,6 +1030,7 @@
 
 	/* Initialize the tty_driver structure */
 
+	hp_simserial_driver->owner = THIS_MODULE;
 	hp_simserial_driver->driver_name = "simserial";
 	hp_simserial_driver->name = "ttyS";
 	hp_simserial_driver->major = TTY_MAJOR;
