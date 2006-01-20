From: Aaron Young <ayoung@google.engr.sgi.com>
Date: Fri, 20 Jan 2006 20:12:41 +0000
Subject: [PATCH] RESEND - SN: Handle SC env. powerdown events
Message-Id: <200601202012.MAA23464@google.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 (Resubmit to fix a couple of alignment/indentation problems
  and remove a couple of superfluous comments)

Handle system controller power down pending events
on SN systems. This allows the system to gracefully shutdown
before the system controller removes power due to
an adverse environmental condition.

Signed-off-by: Aaron Young <ayoung@sgi.com>

---

Index: linux/drivers/char/snsc.h
=================================--- linux.orig/drivers/char/snsc.h	2006-01-02 21:21:10 -06:00
+++ linux/drivers/char/snsc.h	2006-01-20 12:17:52 -06:00
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 /*
@@ -69,6 +69,9 @@ struct sysctl_data_s {
 #define EV_CLASS_TEST_FAULT	0x5000ul
 #define EV_CLASS_TEST_WARNING	0x6000ul
 #define EV_CLASS_PWRD_NOTIFY	0x8000ul
+
+/* ENV class codes */
+#define ENV_PWRDN_PEND		0x4101ul
 
 #define EV_SEVERITY_POWER_STABLE	0x0000ul
 #define EV_SEVERITY_POWER_LOW_WARNING	0x0100ul
Index: linux/drivers/char/snsc_event.c
=================================--- linux.orig/drivers/char/snsc_event.c	2006-01-02 21:21:10 -06:00
+++ linux/drivers/char/snsc_event.c	2006-01-20 13:45:14 -06:00
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 /*
@@ -187,7 +187,8 @@ scdrv_event_severity(int code)
 static void
 scdrv_dispatch_event(char *event, int len)
 {
-	int code, esp_code, src;
+	static int snsc_shutting_down = 0;
+	int code, esp_code, src, class;
 	char desc[CHUNKSIZE];
 	char *severity;
 
@@ -199,9 +200,25 @@ scdrv_dispatch_event(char *event, int le
 	/* how urgent is the message? */
 	severity = scdrv_event_severity(code);
 
-	if ((code & EV_CLASS_MASK) = EV_CLASS_PWRD_NOTIFY) {
+	class = (code & EV_CLASS_MASK);
+
+	if (class = EV_CLASS_PWRD_NOTIFY || code = ENV_PWRDN_PEND) {
 		struct task_struct *p;
 
+		if (snsc_shutting_down)
+			return;
+
+		snsc_shutting_down = 1;
+
+		/* give a message for each type of event */
+		if (class = EV_CLASS_PWRD_NOTIFY)
+			printk(KERN_NOTICE "Power off indication received."
+				" Sending SIGPWR to init...\n");
+		else if (code = ENV_PWRDN_PEND)
+			printk(KERN_CRIT "WARNING: Shutting down the system"
+				" due to a critical environmental condition."
+				" Sending SIGPWR to init...\n");
+
 		/* give a SIGPWR signal to init proc */
 
 		/* first find init's task */
@@ -210,12 +227,11 @@ scdrv_dispatch_event(char *event, int le
 			if (p->pid = 1)
 				break;
 		}
-		if (p) { /* we found init's task */
-			printk(KERN_EMERG "Power off indication received. Initiating power fail sequence...\n");
+		if (p) {
 			force_sig(SIGPWR, p);
-		} else { /* failed to find init's task - just give message(s) */
-			printk(KERN_WARNING "Failed to find init proc to handle power off!\n");
-			printk("%s|$(0x%x)%s\n", severity, esp_code, desc);
+		} else {
+			printk(KERN_ERR "Failed to signal init!\n");
+			snsc_shutting_down = 0; /* so can try again (?) */
 		}
 		read_unlock(&tasklist_lock);
 	} else {
